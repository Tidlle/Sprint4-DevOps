#!/usr/bin/env bash
# Sprint 4 - Infraestrutura do VitalPet na Azure via Azure CLI
# Web App (Linux, Java 17) + Azure SQL Database (PaaS)
# Execute no Azure Cloud Shell (Bash):  bash scripts/infra-azure.sh
set -euo pipefail

# ====== AJUSTE AQUI ======
RM="rm00000"                 # um RM do grupo (minusculo) -> torna os nomes globalmente unicos
LOCATION="eastus2"           # regiao usada na aula; se der erro de policy, tente "canadacentral" ou "brazilsouth"
# =========================

RG="rg-vitalpet-sprint4"
PLAN="plan-vitalpet"
APP="app-vitalpet-${RM}"
SQL_SERVER="sql-vitalpet-${RM}"
SQL_DB="vitalpet"
SQL_USER="vitalpetadmin"

read -r -s -p "Senha do admin do Azure SQL (min. 8 chars, maiuscula, minuscula e numero; NAO use \" \$ \\ \`): " SQL_PASS
echo
if [[ "$SQL_PASS" =~ [\"\$\\\`] ]]; then
  echo "Senha contem caractere nao permitido (\" \$ \\ \`)." >&2; exit 1
fi

echo ">> Resource Group"
az group create --name "$RG" --location "$LOCATION" -o table

echo ">> Registrar o provider Microsoft.Sql (necessario na primeira vez)"
az provider register --namespace Microsoft.Sql

echo ">> Azure SQL Server"
az sql server create \
  --resource-group "$RG" --name "$SQL_SERVER" --location "$LOCATION" \
  --admin-user "$SQL_USER" --admin-password "$SQL_PASS" \
  --enable-public-network true -o table

echo ">> Banco de dados (tier Basic)"
az sql db create \
  --resource-group "$RG" --server "$SQL_SERVER" --name "$SQL_DB" \
  --service-objective Basic --backup-storage-redundancy Local --zone-redundant false -o table

echo ">> Firewall: liberar servicos Azure (Web App)"
az sql server firewall-rule create -g "$RG" -s "$SQL_SERVER" \
  -n AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0 -o table

echo ">> Firewall: liberar o IP da sua maquina para consultar o banco nos SELECTs do video"
read -r -p "Informe o IP publico do seu PC (https://api.ipify.org) ou ENTER para pular: " MY_IP
if [ -n "$MY_IP" ]; then
  az sql server firewall-rule create -g "$RG" -s "$SQL_SERVER" \
    -n AllowMyIP --start-ip-address "$MY_IP" --end-ip-address "$MY_IP" -o table
fi

echo ">> App Service Plan (Linux B1)"
az appservice plan create -g "$RG" -n "$PLAN" --is-linux --sku B1 -o table

echo ">> Web App (Java 17)"
az webapp create -g "$RG" -p "$PLAN" -n "$APP" --runtime "JAVA:17-java17" -o table

echo ">> Configuracoes nao sensiveis do Web App"
az webapp config appsettings set -g "$RG" -n "$APP" --settings \
  SPRING_PROFILES_ACTIVE=sqlserver SERVER_PORT=8080 WEBSITES_PORT=8080 -o none

echo ">> Logs da aplicacao (util para debug)"
az webapp log config -g "$RG" -n "$APP" \
  --application-logging filesystem --docker-container-logging filesystem --level information -o none

echo
echo "================= RESUMO ================="
echo "Web App : https://${APP}.azurewebsites.net"
echo "Swagger : https://${APP}.azurewebsites.net/swagger-ui.html"
echo "Azure SQL: ${SQL_SERVER}.database.windows.net  /  banco ${SQL_DB}"
echo
echo "Variaveis para a Library 'sprint4-secrets' (marque TODAS como secretas):"
echo "DB_URL      = jdbc:sqlserver://${SQL_SERVER}.database.windows.net:1433;database=${SQL_DB};encrypt=true;trustServerCertificate=false;loginTimeout=30;"
echo "DB_USER     = ${SQL_USER}"
echo "DB_PASSWORD = (a senha digitada)"
echo "=========================================="

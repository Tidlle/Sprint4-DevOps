# Sprint 4 – DevOps Tools & Cloud Computing: plano de execução

> Entrega: **04/11/2026**. Fonte: PDF "2TDS Fevereiro – Challenge 2026 – 2º Semestre", seção *4ª Sprint – DevOps Tools & Cloud Computing (1/8 a 8/8)*.

---

## 0. O que o professor pede, resumido

| # | Requisito | Onde fica | Se faltar |
|---|---|---|---|
| 1 | Descrição da solução + stack | README | -10 |
| 2 | Diagrama de arquitetura + fluxo CI/CD numerado, com personas, setas e ferramentas | README (imagem) | até -20 (fluxograma/UML/TOGAF = -20) |
| 3 | Banco em nuvem: Azure SQL, MySQL, PostgreSQL (PaaS) ou Oracle | Azure | -40 se o banco não for permitido |
| 4 | Projeto no Azure DevOps com nome, descrição, Private, Git e Scrum/Agile | Azure DevOps | **zero** se não existir |
| 5 | Professor convidado com acesso **Basic** | Azure DevOps | **zero** |
| 6 | Pipeline CI: build + **testes** + **artefato publicado**, disparo automático na branch **master** | Azure Pipelines | -20 / -20 / -30 |
| 6 | Pipeline CD: dispara **após novo artefato**, faz deploy em **Azure Web App** ou ACI | Azure Pipelines | -30 |
| 6 | Senhas, usuários e tokens em **variáveis protegidas** | Library / variáveis secretas | -15 |
| 8 | Vídeo em 720p ou mais, com voz, sem legenda, seguindo o fluxo pedido | YouTube | -30 se a qualidade for ruim |
| — | PDF contendo **apenas** nomes completos, RM e turma, link do GitHub, link do YouTube e link do projeto no Azure DevOps | Entrega | -30 |

**Zeram a nota:** app rodando em localhost, entrega atrasada, professor sem acesso ao DevOps ou ao vídeo, projeto não configurado, CI ou CD sem funcionar.

**Pontuação:** diagrama vale 20 pontos e o vídeo vale 80.

---

## 1. Arquitetura recomendada (projeto Clyvo VitalPet)

**Projeto:** `C:\Users\educa\Documents\GitHub\Sprint4-Java`. É Spring Boot 3.3.5 com Java 17, Maven, Flyway, JPA, Thymeleaf e Spring Security, e já traz 9 testes JUnit.

**Escolha:** Web App Linux (Java 17) + **Azure SQL Database** (PaaS) + 2 pipelines YAML no Azure DevOps.

```
Dev ──push──▶ GitHub (master) ──trigger──▶ Pipeline CI (sprint4-ci)
                                             ├─ mvn clean package (build)
                                             ├─ 9 testes JUnit (H2 em memória) + resultados publicados
                                             └─ publica artefato "drop" (clyvo-vitalpet-1.0.0.jar)
                                                      │ (novo artefato)
                                                      ▼
                                           Pipeline CD (sprint4-cd)
                                             ├─ baixa o artefato
                                             ├─ lê segredos da Library (sprint4-secrets)
                                             └─ deploy ─▶ Azure Web App ──▶ Azure SQL Database
                                                                 ▲
                                                 Usuário final ──┘ (HTTPS)
```

O CD usa `resources.pipelines` com `trigger`, então dispara literalmente "após novo artefato" e o vídeo mostra "Triggered by sprint4-ci".

**Arquivos prontos em [`projeto-java/`](projeto-java/)**, que espelham a estrutura do seu repositório:

| Arquivo | Destino no repositório | O que é |
|---|---|---|
| `pom.xml` | raiz (substitui) | Só adiciona `mssql-jdbc` e `flyway-sqlserver` |
| `src/main/resources/application-sqlserver.properties` | mesmo caminho | Perfil `sqlserver`: lê URL, usuário e senha de variáveis de ambiente |
| `src/main/resources/db/migration-sqlserver/V1, V2` | mesmo caminho | Schema e seed em T-SQL (`IDENTITY`, `BIT`, `DATETIME2`, `sp_addextendedproperty` no lugar de `COMMENT ON`) |
| `azure-pipelines-ci.yml` e `azure-pipelines-cd.yml` | raiz | Pipelines de CI e CD |
| `scripts/infra-azure.sh` | `scripts/` | Cria os recursos Azure via CLI |

**Por que não mexi no que já funciona:** o perfil padrão continua com H2, então `./mvnw spring-boot:run` e os testes seguem iguais. O H2 só deixa de ser o banco **da nuvem**. As migrations do Azure SQL ficam em `db/migration-sqlserver` (fora de `db/migration`), porque o Flyway varre subpastas e misturaria as duas versões.

---

## 2. Passo a passo

### ETAPA A — Pré-requisitos (faça HOJE: A2 demora dias)

**A1. Criar a organização no Azure DevOps**
1. Acesse https://dev.azure.com e entre com a mesma conta da assinatura Azure (Azure for Students).
2. Clique em **New organization**, escolha um nome (ex.: `vitalpet-fiap`) e a região **Brazil**.

**A2. ⚠️ Liberar o agente para rodar as pipelines**
O formulário antigo de paralelismo foi **desativado**. Hoje a regra é:
- **Agente self-hosted (no seu PC):** 1 job paralelo gratuito é concedido **automaticamente**, sem limite de tempo. É a opção recomendada.
- **Agente Microsoft-hosted (`ubuntu-latest`):** só é liberado depois de **configurar o billing**, ou seja, vincular uma assinatura Azure à organização (Organization settings → Billing → Set up billing). O plano gratuito dá 1 job de até 60 min e 1.800 min/mês, sem cobrança.

Sem nenhum dos dois, a pipeline fica na fila com o erro *"No hosted parallelism has been purchased or granted"*.

Agente self-hosted no PC (passo a passo):
1. Crie um PAT (ícone de usuário → Personal access tokens → New Token, escopo **Agent Pools: Read & manage**).
2. Organization settings → Pipelines → Agent pools → Default → **New agent** → Windows x64 → baixe o zip.
3. No PowerShell: `mkdir C:gent`, extraia o zip lá e rode `.\config.cmd` (URL `https://dev.azure.com/<org>`, auth PAT, pool `Default`, não rodar como serviço).
4. `setx JAVA_HOME_21_X64 "C:\Program Files\Java\jdk-21.0.10"`, abra um PowerShell novo e rode `.
un.cmd`. Deixe a janela aberta.
5. Nos dois YAML, use `pool: { name: Default }` e, no CI, `jdkVersionOption: '1.21'`.

**A3. Repositório no GitHub**
1. **A pasta `Sprint4-Java` não é um repositório Git** (não tem `.git`). Crie um repositório vazio no GitHub e envie o código:
   ```bash
   cd C:\Users\educa\Documents\GitHub\Sprint4-Java
   git init -b master
   git add .
   git commit -m "Projeto VitalPet - Sprint 4"
   git remote add origin https://github.com/<usuario>/<repositorio>.git
   git push -u origin master
   ```
   A branch precisa se chamar **`master`**, porque o requisito II exige isso.
2. Antes do `git add`, acrescente ao `.gitignore`: `.claude/` e `.idea/`. A pasta `target/` já está lá.
3. Se o repositório for privado, dê acesso de leitura ao professor.
4. O `README.md` atual descreve a Sprint 3. Reescreva-o na etapa H.

**A4. Copiar os arquivos de `projeto-java/` para o repositório** (tabela da seção 1)
```powershell
Copy-Item -Recurse -Force C:\Users\educa\Downloads\Sprint4-DevOps\projeto-java\* C:\Users\educa\Documents\GitHub\Sprint4-Java\
```
Depois confirme que o projeto ainda passa nos testes: `.\mvnw.cmd test`.
Já rodei isso numa cópia: **9 testes, 0 falhas**.

**A5. Sobre os testes no CI**
- Os testes (`ClyvoVitalpetApplicationTests`, `SecurityConfigTest`, `AlertaServiceTest`) usam o perfil padrão com **H2 em memória**, então o CI não depende do banco da nuvem. Isso é permitido: o H2 é proibido como banco da aplicação, não como banco de teste.
- Se quiser reforçar o item "testes automáticos", adicione mais 2 ou 3 testes (por exemplo, de `ClinicaService`).

**A6. Senhas no código**
Não há senha de banco no código (o H2 usa `sa` sem senha). As senhas dos usuários de demonstração do app (`VitalPet@123`) estão no seed como hash BCrypt, e isso é aceitável. As credenciais do **Azure SQL** só existem na Library do Azure DevOps.

---

### ETAPA B — Recursos na Azure (via Azure CLI)

1. No Portal Azure, abra o **Cloud Shell (Bash)** e faça upload de `scripts/infra-azure.sh`.
2. Edite as variáveis do topo: `RM` (um RM do grupo, em minúsculas) e `LOCATION`.
3. Rode `bash infra-azure.sh`. Ele pede a senha do Azure SQL sem mostrá-la (não use `"`, `$`, `\` nem crase).
4. Ele cria:
   - Resource Group `rg-vitalpet-sprint4`
   - Azure SQL Server `sql-vitalpet-<RM>` e o banco `vitalpet` (tier Basic), com firewall liberado para serviços Azure
   - Regra de firewall para o IP do seu PC (opcional, necessária para os SELECTs do vídeo; veja seu IP em https://api.ipify.org)
   - App Service Plan Linux B1 e Web App `app-vitalpet-<RM>` com Java 17
   - Configurações `SPRING_PROFILES_ACTIVE=sqlserver`, `SERVER_PORT=8080` e `WEBSITES_PORT=8080`
5. No fim, o script **imprime os valores de `DB_URL`, `DB_USER` e `DB_PASSWORD`**. Guarde-os, porque vão para a Library na etapa E.
6. **Não crie as tabelas à mão.** O Flyway cria o schema e o seed (clínicas, vets, pets, usuários) no primeiro start do app, pelo CD.

> Azure for Students restringe regiões e SKUs. O script usa `eastus2`, a região da aula. Se o Azure SQL ou o plano B1 derem erro, troque `LOCATION` (`canadacentral`, `brazilsouth`) e rode de novo.

---

### ETAPA C — Projeto no Azure DevOps (requisito 4)

1. Em dev.azure.com/<sua-org>, clique em **+ New project** e preencha:
   - **Project name:** `Sprint 4 - Azure DevOps`
   - **Description:**
     ```
     Projeto para entrega da Sprint 4 do professor <NOME DO PROFESSOR>
     Integrantes do grupo:
     RM00000 - Nome Completo - 2TDSx
     RM00000 - Nome Completo - 2TDSx
     ```
   - **Visibility:** Private
   - **Advanced:** Version control **Git** e Work item process **Scrum** (ou Agile)
2. Clique em **Create**.

### ETAPA D — Convidar o professor (requisito 5: sem isso a nota é ZERO)

1. **Organization settings** (canto inferior esquerdo) → **Users** → **Add users**.
2. Preencha:
   - E-mail do professor
   - **Access level: Basic**
   - **Add to projects:** Sprint 4 - Azure DevOps
   - **Azure DevOps Groups:** Project Contributors
3. Clique em **Add**.
4. Se o e-mail dele for de outro domínio e o convite falhar, ligue a opção **Organization settings → Policies → External guest access**.
5. Confira em Users se ele aparece com o nível **Basic**. A org dá 5 usuários Basic grátis.

### ETAPA E — Conexões e segredos

**E1. Service connection com a Azure**
1. Vá em Project settings → **Service connections** → New → **Azure Resource Manager**.
2. Escolha **Workload Identity federation (automatic)**, scope **Subscription**, resource group `rg-vitalpet-sprint4`.
3. Nome: **`sc-azure-sprint4`**. É exatamente o nome usado nos YAML.
4. Marque **Grant access permission to all pipelines** e salve.

**E2. Variáveis protegidas (requisito IV)**
1. Vá em Pipelines → **Library** → **+ Variable group**, com o nome **`sprint4-secrets`**.
2. Adicione estas três variáveis e clique no **cadeado 🔒** de cada uma para torná-la secreta:

   | Variável | Valor |
   |---|---|
   | `DB_URL` | `jdbc:sqlserver://sql-vitalpet-<RM>.database.windows.net:1433;database=vitalpet;encrypt=true;trustServerCertificate=false;loginTimeout=30;` |
   | `DB_USER` | `vitalpetadmin` |
   | `DB_PASSWORD` | (a senha que você digitou no script) |

3. Em **Pipeline permissions** do grupo, libere o acesso da pipeline `sprint4-cd`. Outra opção é clicar em "Permit" na primeira execução.

### ETAPA F — Pipelines

1. Os arquivos `azure-pipelines-ci.yml` e `azure-pipelines-cd.yml` já foram para a **raiz do repositório** na etapa A4.
2. Em `azure-pipelines-cd.yml`, ajuste `webAppName` para o nome real do seu Web App (`app-vitalpet-<RM>`).
3. Faça commit e push para `master`.
4. Crie a **pipeline de CI**:
   1. Pipelines → **New pipeline** → **GitHub** → autorize o *Azure Pipelines* GitHub App → selecione o repositório.
   2. Escolha **Existing Azure Pipelines YAML file** → `/azure-pipelines-ci.yml` → **Run**.
   3. Depois vá em ⋯ → **Rename/move** e dê o nome **`sprint4-ci`**. Esse nome precisa ser idêntico ao `source:` do CD.
5. Crie a **pipeline de CD** do mesmo jeito, com `/azure-pipelines-cd.yml`, e renomeie para **`sprint4-cd`**.
6. Rode o CI manualmente uma vez e confira os pontos abaixo:
   - [ ] Aba **Tests** mostra os testes que passaram
   - [ ] Ao lado de "Related" aparece **1 published** (é o artefato `drop`)
   - [ ] O CD iniciou sozinho com o texto "Triggered by sprint4-ci"
   - [ ] Os segredos aparecem como `***` nos logs
   - [ ] A URL `https://app-vitalpet-<RM>.azurewebsites.net` responde
7. Teste o CRUD completo no Web App e confira no banco com SELECT.

> **Plano alternativo (modo clássico):** também é aceito. Crie o CI em YAML e um **Release pipeline** clássico com o artefato do CI e o gatilho ⚡ *Continuous deployment trigger* ligado. Se a opção "Release" não aparecer, desative *Disable creation of classic release pipelines* em Organization settings → Pipelines → Settings.

### ETAPA G — Diagrama de arquitetura (20 pontos)

> **Diagrama:** use [`diagrama/arquitetura-DevOps.png`](diagrama/arquitetura-DevOps.png) (copiado para `docs/arquitetura-DevOps.png` no repositório e referenciado no README). **Confira que as setas estão numeradas de 1 a 10**, porque o PDF exige "números indicando a ordem". O texto abaixo descreve o conteúdo esperado.

Monte o diagrama no **draw.io (diagrams.net)**, ligando a biblioteca de ícones **Azure** em *More shapes → Networking/Azure*. **Não pode parecer fluxograma, UML ou TOGAF.** Precisa ser um desenho de arquitetura com ícones.

- **Personas** (ícone de pessoa): *Desenvolvedor*, *Usuário final* e *Professor/Avaliador* (opcional)
- **Componentes:**
  - IDE (IntelliJ ou VS Code) e GitHub
  - Azure DevOps (Boards, Pipelines, Library, Artifacts) e Service Connection
  - Azure App Service (Plan + Web App) e Azure SQL Database
  - Resource Group envolvendo os recursos Azure
- **Setas numeradas:**
  1. Dev faz commit e push na `master` (IDE → GitHub)
  2. GitHub dispara o **CI** (Azure Pipelines)
  3. CI: restore e build
  4. CI: testes automatizados e publicação dos resultados
  5. CI: publica o **artefato** `drop`
  6. Novo artefato dispara o **CD**
  7. CD lê os **segredos** do Variable Group
  8. CD faz o **deploy** via Service Connection → **Azure Web App**
  9. Web App ↔ **Azure SQL Database** (JDBC)
  10. Usuário final acessa a app/API por HTTPS
- Escreva uma legenda curta sob cada ferramenta dizendo "onde atua". Exporte em PNG e coloque em `docs/arquitetura.png` no README.

### ETAPA H — README e PDF

**README.md** precisa ter:
- Nome da solução e descrição (o que faz e para quem)
- **Stack** (linguagem, framework, banco, Azure App Service, Azure SQL, Azure DevOps, GitHub)
- Diagrama e explicação do fluxo numerado
- Tabela das pipelines (CI e CD: gatilhos, tarefas, artefato)
- Recursos Azure e o script `infra-azure.sh`
- Endpoints do CRUD com exemplos de JSON
- `script_bd.sql`
- Integrantes

**PDF** tem **somente**:
- Nome completo, RM e turma de cada integrante
- Link do GitHub
- Link do YouTube (não listado ou público, **nunca privado**)
- Link do projeto: `https://dev.azure.com/<org>/Sprint%204%20-%20Azure%20DevOps`

### ETAPA I — Preparação do vídeo (checklist pré-gravação)

- [ ] Paralelismo liberado e pipelines rodaram verdes pelo menos 1 vez
- [ ] Abas abertas:
  - IDE com o código
  - GitHub
  - Azure DevOps (Pipelines, Library, Project settings e Users)
  - Portal Azure (Resource Group, Web App, SQL)
  - **Query editor** do Portal Azure (banco → Query editor) ou Azure Data Studio / SSMS, conectado ao Azure SQL com o seu IP liberado no firewall
  - Postman/Insomnia ou Swagger
- [ ] `git push` testado (credencial ok)
- [ ] Mudança visível escolhida **no código**, nunca no README (-20). Exemplos: título do Swagger, mensagem de um endpoint `/`, label de uma tela
- [ ] Queries SELECT prontas num arquivo `.sql`
- [ ] JSONs do CRUD prontos no Postman
- [ ] Web App "acordado": acesse a URL 1 minuto antes de gravar
- [ ] Gravador em 1080p (OBS: Settings → Video 1920x1080, 30fps) e microfone testado
- [ ] Zoom do navegador e da IDE em 125–150% para ficar legível
- [ ] Notificações desligadas e nenhuma senha visível na tela

### ETAPA J — Depois de gravar

- Assista ao vídeo inteiro e confira que a tela está legível e o áudio está ok.
- Suba no YouTube como **Não listado**.
- Abra o link numa aba anônima para confirmar o acesso.
- Confirme que o professor aparece em Users com acesso Basic.
- Entregue **antes** de 04/11/2026.
- **Não delete os recursos Azure** até receber a nota (feedback em 11/11/2026).

---

## 3. Cronograma sugerido

| Data | Atividade |
|---|---|
| 29–30/09 | Etapa A, incluindo o pedido de paralelismo |
| até 10/10 | Etapas B, C, D, E |
| até 20/10 | Etapa F: pipelines verdes e CRUD funcionando na nuvem |
| até 25/10 | Etapas G e H: diagrama, README, PDF |
| até 30/10 | Etapa I e gravação do vídeo |
| até 02/11 | Revisão final e entrega (com folga) |

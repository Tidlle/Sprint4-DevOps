# Roteiro do vídeo – Sprint 4 DevOps (CI/CD com Azure DevOps)

**Duração estimada:** de 20 a 25 minutos, com as esperas da pipeline.
**Requisitos do vídeo:** 720p ou mais (grave em 1080p), voz clara, **sem legendas**.

**Como ler este roteiro:**
- **[TELA]** diz o que mostrar. **[FALA]** é o texto sugerido para ler.
- Troque os `<campos>` pelos dados do seu projeto.
- Fale com naturalidade: não precisa decorar, só não pule nenhum item.

**Antes de começar:** veja o arquivo `CHECKLIST_GRAVACAO.md`. O agente (`run.cmd`) precisa estar aberto e a aplicação "acordada" no navegador.

**Tempos de espera na gravação (use para explicar, nunca corte):**

| Etapa | Duração aproximada |
|---|---|
| Início automático do CI após o push | 10 a 30 segundos |
| CI (build, testes, artefato) | 2 a 5 minutos |
| CD (download e deploy) | 1 a 3 minutos |
| Reinício do app Java depois do deploy | 1 a 2 minutos |

> **Regra de ouro:** não corte o vídeo entre o commit e o fim do CRUD. Enquanto a pipeline roda, **explique** cada etapa (isso vale -20 pontos se faltar). Use o tempo de espera, não o corte.

---

## Cena 1 — Abertura (≈ 0:30)

**[TELA]** Slide simples ou o README aberto no GitHub com o nome do projeto e os integrantes.

**[FALA]**
> "Olá, professor. Meu nome é `<nome completo>`, RM `<RM>`, da turma `<2TDSx>`. [Se houver grupo: 'Junto comigo estão `<nomes e RMs>`.']
> Este é o vídeo da Sprint 4 de DevOps Tools e Cloud Computing. Vou apresentar a solução **Clyvo VitalPet**, a arquitetura e as esteiras de CI/CD no Azure DevOps. No fim, vou demonstrar uma alteração de código indo automaticamente para produção no Azure e o CRUD completo com evidência no banco de dados."

---

## Cena 2 — Descrição da solução e stack (≈ 1:00)

**[TELA]** README no GitHub, seção "Descrição" e "Stack". Se preferir, mostre a tela de login/dashboard da aplicação.

**[FALA]**
> "O **Clyvo VitalPet** é uma aplicação de gestão veterinária que acompanha o pet **depois** da consulta. Quando o veterinário finaliza um atendimento, o sistema cria automaticamente um acompanhamento clínico e um alerta de retorno. A aplicação gerencia clínicas, veterinários, tutores, pets, consultas e alertas, com login e permissões por perfil. Ela resolve a perda de informação após o atendimento.
> A stack é:
> - **Java 17 com Spring Boot 3**, usando Spring Data JPA, Spring Security e Thymeleaf;
> - **Flyway** para versionar o schema do banco;
> - **JUnit** para os testes automatizados e **Maven** para o build;
> - banco **Azure SQL Database**, que é um banco PaaS na nuvem;
> - hospedagem no **Azure App Service**, com um Web App Linux;
> - código no **GitHub**, e **Azure DevOps** para a gestão do projeto e as pipelines de CI e CD."

---

## Cena 3 — Diagrama de arquitetura + fluxo CI/CD (≈ 1:30)

**[TELA]** Imagem do diagrama (`docs/arquitetura-DevOps.png`) em tela cheia. Aponte com o mouse cada número.

**[FALA]**
> "Este é o diagrama da arquitetura com o fluxo de CI/CD. Temos duas personas: o **desenvolvedor** e o **usuário final**.
> 1. O desenvolvedor altera o código na IDE e faz o push para a branch **master** do GitHub.
> 2. Esse push dispara automaticamente a pipeline de **CI** no Azure Pipelines.
> 3. O CI faz o build da aplicação,
> 4. roda os testes automatizados e publica os resultados,
> 5. e gera e publica o **artefato** dentro do Azure DevOps.
> 6. Quando um novo artefato é gerado, a pipeline de **CD** dispara sozinha.
> 7. O CD lê as credenciais do banco na **Library** (variable group), onde elas ficam protegidas como variáveis secretas,
> 8. e faz o deploy no **Azure Web App** por meio de uma Service Connection com a Azure.
> 9. O Web App se conecta ao **Azure SQL Database**.
> 10. Por fim, o usuário final acessa a aplicação pela internet via HTTPS.
>
> Todos os recursos da Azure ficam no resource group `rg-vitalpet-sprint4`."

---

## Cena 4 — Ferramentas utilizadas (≈ 2:00)

Passe rapidamente por cada aba já aberta.

**[TELA]** IDE com o projeto aberto.
**[FALA]**
> "Aqui está a IDE `<IntelliJ / VS Code>` com o código da aplicação. Na raiz estão os dois arquivos das pipelines: `azure-pipelines-ci.yml` e `azure-pipelines-cd.yml`."

**[TELA]** GitHub, com o repositório na branch master.
**[FALA]**
> "Este é o repositório no GitHub. A branch principal é a `master`, que é a que dispara as pipelines."

**[TELA]** Azure DevOps → Project settings → Overview (nome, descrição, visibilidade).
**[FALA]**
> "No Azure DevOps, o projeto se chama **Sprint 4 - Azure DevOps**. A descrição cita o professor e os integrantes. A visibilidade é **privada**, o controle de versão é **Git** e o processo é **Scrum**."

**[TELA]** Organization settings → Users (professor com Basic).
**[FALA]**
> "O professor `<nome>` foi convidado para o projeto com o nível de acesso **Basic**."

**[TELA]** Portal Azure → Resource group `rg-vitalpet-sprint4`.
**[FALA]**
> "No Portal da Azure, dentro do resource group, temos o App Service Plan, o Web App `<nome>`, o servidor SQL e o banco `vitalpet`. Todos foram criados via Azure CLI com o script `scripts/infra-azure.sh`, que está no repositório."

**[TELA]** Query editor do Portal Azure (banco `vitalpet` → Query editor) ou Azure Data Studio / SSMS, conectado ao Azure SQL.
**[FALA]**
> "E aqui estou conectado ao Azure SQL, onde vou fazer os SELECTs para comprovar a persistência do CRUD."

---

## Cena 5 — Configuração das pipelines (≈ 3:00)

**[TELA]** Azure DevOps → Pipelines (lista com `sprint4-ci` e `sprint4-cd`) e depois **Edit** do `sprint4-ci`.

**[FALA] – CI**
> "Temos duas pipelines em YAML: a `sprint4-ci` e a `sprint4-cd`. Começando pelo CI:
> - O **trigger** está configurado na branch `master`. Toda alteração de código nessa branch dispara o CI automaticamente.
> - Ele roda em um **agente self-hosted**, instalado na minha máquina, no pool `Default`. [Mostre a janela do `run.cmd` com `Listening for Jobs`.]
> - O **stage CI** tem um job com estas tasks:
>   - primeiro, a task do **Maven**, que compila, roda os testes e empacota o `.jar`;
>   - os resultados dos testes são publicados para aparecerem na aba **Tests**;
>   - depois, o `.jar` é copiado para a área de staging;
>   - e por último, a task **Publish Pipeline Artifact** publica o artefato chamado `drop` no Azure DevOps."

**[TELA]** Edit do `sprint4-cd`.

**[FALA] – CD**
> "Agora o CD:
> - Ele tem `trigger: none`, ou seja, **não** dispara por commit.
> - Em `resources.pipelines` ele aponta para a `sprint4-ci` com trigger. Então o CD dispara **sempre que o CI termina e gera um novo artefato**.
> - Ele usa o variable group `sprint4-secrets`.
> - O job de deploy tem estas tasks:
>   - o **download** do artefato gerado pelo CI;
>   - a task **Azure Web App**, que usa a Service Connection `sc-azure-sprint4` para publicar o pacote no Web App e configurar as variáveis de ambiente de conexão com o banco;
>   - e, no final, a impressão da URL da aplicação."

**[TELA]** Pipelines → Library → `sprint4-secrets` (mostre os cadeados, **sem revelar valores**).

**[FALA]**
> "Aqui na Library estão as variáveis sensíveis: `DB_URL, DB_USER e DB_PASSWORD`. Todas estão marcadas como **secretas** com o cadeado. Elas não ficam no código-fonte e aparecem mascaradas nos logs."

**[TELA]** Project settings → Service connections → `sc-azure-sprint4`.

**[FALA]**
> "E esta é a Service Connection que autoriza o Azure DevOps a fazer deploy na minha assinatura da Azure, usando Workload Identity Federation, sem precisar guardar senha."

---

## Cena 6 — Estado atual da aplicação (antes da alteração) (≈ 0:40)

**[TELA]** Navegador em `https://app-vitalpet-<RM>.azurewebsites.net/swagger-ui.html`, com o título da API visível no topo ("Clyvo VitalPet API").

**[FALA]**
> "Esta é a aplicação rodando hoje no Azure Web App. Repare no título do Swagger: `Clyvo VitalPet API`. Vou alterar esse título no código para comprovar o fluxo de CI/CD."

---

## Cena 7 — Alteração no código + commit + push (≈ 1:00)

**[TELA]** IDE: abra `src/main/java/com/clyvo/vitalpet/config/OpenApiConfig.java` e mude o título (é **código**, não README):
```java
.title("Clyvo VitalPet API v2")
```
Em seguida, no terminal da IDE:
```bash
git add .
git commit -m "feat: altera titulo da API para v2 (demonstracao CI/CD)"
git push origin master
```

**[FALA]**
> "Estou alterando, na classe `OpenApiConfig`, o título da API de `Clyvo VitalPet API` para `Clyvo VitalPet API v2`. Agora vou fazer o commit e o push direto na branch master."

**[TELA]** Mostre o commit aparecendo no GitHub, rapidamente.

---

## Cena 8 — CI disparando e rodando (≈ 3:00, ao vivo)

**[TELA]** Azure DevOps → Pipelines → `sprint4-ci`: mostre a nova execução **iniciada sozinha**, com o nome do commit e o ícone "Triggered by… CI" / "Individual CI". Clique na execução e no job para abrir os logs ao vivo.

**[FALA]** (vá falando conforme cada step fica verde)
> "O CI iniciou **automaticamente** assim que fiz o push. Aqui aparece a mensagem do meu commit e que ele foi disparado pela branch master.
> Vou abrir os detalhes da execução:
> - **Initialize job / Checkout:** o agente é preparado e baixa o código do GitHub, no commit que acabei de enviar.
> - `mvn clean package`: aqui ele baixa as dependências e compila a aplicação. Se houvesse erro de compilação, a esteira pararia aqui.
> - **Testes:** aqui rodam os testes automatizados JUnit. Estão sendo executados 9 testes: contexto da aplicação, segurança por perfil e serviço de alertas. Se algum teste falhar, o artefato não é gerado e nada vai para produção. Essa é a garantia de qualidade do CI.
> - **Copy files:** o `.jar` gerado é copiado para a área de staging, que é o pacote que será implantado.
> - **Publish Pipeline Artifact:** o pacote é publicado como artefato `drop` dentro do Azure DevOps.
> - Finalize: o agente é liberado. O CI terminou com sucesso."

---

## Cena 9 — Artefato e resultados dos testes (≈ 1:00)

**[TELA]** Na página de resumo da execução do CI: clique em **"1 published"** → pasta `drop` → arquivo `clyvo-vitalpet-1.0.0.jar`. Depois abra a aba **Tests**.

**[FALA]**
> "No resumo da execução, aqui está o artefato publicado: a pasta `drop` com o arquivo `clyvo-vitalpet-1.0.0.jar` da aplicação. É exatamente esse pacote que o CD vai implantar.
> Na aba **Tests** vemos que 9 testes foram executados, **100% aprovados**, com o tempo de cada um. `[Se houver: 'e aqui a cobertura de código'.]`"

---

## Cena 10 — CD disparando e rodando (≈ 2:00, ao vivo)

**[TELA]** Pipelines → `sprint4-cd`: mostre a execução iniciada automaticamente com **"Triggered by sprint4-ci"**. Abra o job e os logs.

**[FALA]**
> "Assim que o CI gerou o novo artefato, a pipeline de CD disparou **sozinha**. Olha aqui: 'triggered by sprint4-ci', vinculada à mesma execução do CI.
> Abrindo os detalhes:
> - **Download artifact:** baixa o artefato `drop` gerado pelo CI. Não recompilamos nada, implantamos exatamente o que foi testado.
> - **Azure Web App deploy:** usando a Service Connection, ele publica o pacote no Web App `<nome>` e aplica as configurações de conexão com o banco. Vejam que os valores das variáveis secretas aparecem como **três asteriscos** no log, porque estão protegidos.
> - **URL da aplicação:** aqui ele mostra o endereço publicado.
> O deploy terminou com sucesso."

---

## Cena 11 — Recursos atualizados no Portal Azure (≈ 1:00)

**[TELA]** Portal → Web App `<nome>`:
- **Overview:** status Running e URL
- **Deployment Center → Logs:** o deploy de agora, com data e hora
- **Settings → Environment variables:** mostre os nomes das variáveis, **não os valores**

**[FALA]**
> "No Portal da Azure, no Web App, o status está **Running**. No Deployment Center aparece o deploy que acabou de acontecer, com o horário de agora, feito pelo Azure DevOps. Em Environment variables estão as configurações de conexão com o banco que o CD aplicou. Os valores ficam ocultos."

---

## Cena 12 — Aplicação com a alteração (≈ 1:00)

**[TELA]** Navegador: atualize `/swagger-ui.html` (Ctrl+F5). Depois abra `/web/login` e entre com `admin@vitalpet.com.br` (a senha de demonstração está no README; não precisa falar em voz alta). Mostre o dashboard por alguns segundos.

**[FALA]**
> "Atualizando o Swagger no Web App, o título agora é `Clyvo VitalPet API v2`. Isso comprova que a alteração de código passou pelo build, pelos testes, gerou o artefato e foi implantada automaticamente na Azure, sem nenhuma intervenção manual.
> E aqui está a aplicação web completa rodando na nuvem: o login, e o dashboard com os dados que vêm do banco Azure SQL."

---

## Cena 13 — CRUD completo com evidência no banco (≈ 4:00)

**[TELA]** Divida a tela ou alterne entre o Swagger/Postman (URL do **Web App**, nunca localhost!) e o **Query editor do Portal Azure** (ou Azure Data Studio / SSMS), conectado em `sql-vitalpet-<RM>.database.windows.net`, banco `vitalpet`.

Deixe prontas as queries:
```sql
SELECT id, nome, cnpj, telefone, ativa FROM clinicas ORDER BY id DESC;
SELECT id, nome, cnpj, telefone, ativa FROM clinicas WHERE id = <ID>;
```
> O seed do Flyway já cria 2 clínicas (ids 1 e 2). O registro novo vai ter o id 3.

**0) Banco criado pelo Flyway** (opcional, 20 segundos)
**[FALA]**
> "O schema deste banco foi criado automaticamente pelo Flyway no primeiro start da aplicação, no deploy. Aqui a tabela `flyway_schema_history` mostra as duas migrations aplicadas."
**[TELA]** `SELECT version, description, success FROM flyway_schema_history;`

**1) CREATE**
**[TELA]** Swagger → `POST /api/clinicas` com o JSON abaixo → resposta **201**.
```json
{
  "nome": "Clínica VitalPet Demo",
  "endereco": "Rua da Demonstração, 100",
  "cidade": "São Paulo",
  "estado": "SP",
  "cep": "01310000",
  "telefone": "11999990000",
  "email": "demo@vitalpet.com",
  "cnpj": "12345678000199"
}
```
**[FALA]**
> "Vou começar pelo **insert**. Estou fazendo um POST na API que está no Web App, na nuvem, cadastrando uma clínica. Retornou 201 Created com o id `<ID>`.
> Agora no banco: `SELECT ... FROM clinicas WHERE id = <ID>`. O registro está gravado no Azure SQL."

**2) READ**
**[TELA]** `GET /api/clinicas/<ID>` e `GET /api/clinicas?nome=demo`.
**[FALA]**
> "Agora a **consulta**: o GET por id e o GET com filtro por nome retornam a clínica que acabei de criar. No banco, o `SELECT * FROM clinicas` mostra os mesmos dados que a API retornou."

**3) UPDATE**
**[TELA]** `PUT /api/clinicas/<ID>` com o mesmo JSON, mudando `"nome": "Clínica VitalPet Demo ATUALIZADA"` e `"telefone": "11888880000"` → **200**.
**[FALA]**
> "Agora o **update**: vou alterar o nome e o telefone da clínica. Retornou 200.
> No banco, rodando o SELECT de novo, o nome e o telefone já estão com os novos valores."

**4) DELETE**
**[TELA]** `DELETE /api/clinicas/<ID>` → **204**. Rode o SELECT e destaque a coluna `ativa` indo de `1` para `0`.
**[FALA]**
> "Por fim, o **delete**. Nesta aplicação a exclusão é **lógica**: o registro é desativado em vez de apagado, para preservar o histórico clínico. Retornou 204 No Content.
> No banco, o SELECT mostra que a coluna `ativa` mudou de 1 para 0, ou seja, a clínica foi excluída do sistema e não aparece mais nas listagens ativas."

> **Atenção:** o professor pede evidência clara de **cada** operação (-30 se faltar). Como o DELETE da API é lógico, explique isso em voz alta, como acima. Se quiser evidência de remoção física, peça para eu adicionar um `DELETE` real.

---

## Cena 14 — Encerramento (≈ 0:30)

**[TELA]** Volte para a lista de Pipelines, com as duas execuções verdes, ou para o diagrama.

**[FALA]**
> "Recapitulando: temos o projeto configurado no Azure DevOps, com o professor como Basic. A pipeline de CI dispara a cada alteração na master, compila, executa os testes e publica o artefato. A pipeline de CD dispara automaticamente com o novo artefato e faz o deploy no Azure Web App, com as credenciais protegidas em variáveis secretas. E a aplicação funciona na nuvem, integrada ao Azure SQL, com o CRUD completo comprovado no banco.
> Os links do repositório, do projeto no Azure DevOps e deste vídeo estão no PDF da entrega. Obrigado, professor!"

---

## Checklist rápido durante a gravação (cole ao lado do monitor)

- [ ] Nome, RM e turma no início
- [ ] Descrição da solução e stack
- [ ] Diagrama explicado pelos números
- [ ] Todas as ferramentas mostradas (IDE, GitHub, DevOps, Portal, banco)
- [ ] Nome, descrição e visibilidade do projeto mostrados, e professor como Basic
- [ ] YAML do CI e do CD explicados task por task
- [ ] Variáveis secretas (cadeado) mostradas
- [ ] Alteração **no código** (não no README), com commit e push na master
- [ ] CI iniciou sozinho, com cada step explicado ao vivo
- [ ] Artefato `drop` e aba Tests mostrados
- [ ] CD iniciou sozinho ("Triggered by sprint4-ci"), com cada step explicado
- [ ] Portal: Web App atualizado (Deployment Center)
- [ ] App na nuvem com a alteração visível
- [ ] INSERT, SELECT, UPDATE, SELECT, DELETE, SELECT, todos no banco
- [ ] Nenhuma senha aparecendo na tela

# Checklist: tudo que você precisa para gravar o vídeo

Marque cada item. O vídeo só deve ser gravado quando **todos** estiverem prontos.

## 1. Contas e acessos
- [ ] Organização criada no Azure DevOps e projeto **Sprint 4 - Azure DevOps** (Private, Git, Scrum)
- [ ] Descrição do projeto com o professor, RM, nome e turma de cada integrante
- [ ] Professor convidado com acesso **Basic** (Organization settings → Users)
- [ ] Assinatura Azure ativa, com acesso ao Portal
- [ ] Repositório no GitHub com a branch **master** e o código enviado
- [ ] Conta do YouTube para subir o vídeo (como **Não listado** ou **Público**)

## 2. Infraestrutura na Azure (criada **antes** de gravar)
- [ ] Resource Group `rg-vitalpet-sprint4`
- [ ] Azure SQL Server e banco `vitalpet`
- [ ] App Service Plan e Web App `app-vitalpet-<RM>`
- [ ] Firewall do SQL liberando serviços Azure **e o IP do seu PC**
- [ ] Senha do banco anotada fora do repositório

## 3. Azure DevOps configurado
- [ ] Agente self-hosted **Online** (`run.cmd` aberto, `Listening for Jobs`)
- [ ] `JAVA_HOME_21_X64` definida e `mvn -v` funcionando
- [ ] Service Connection `sc-azure-sprint4`
- [ ] Variable group `sprint4-secrets` com `DB_URL`, `DB_USER`, `DB_PASSWORD` (todas com cadeado)
- [ ] Pipelines `sprint4-ci` e `sprint4-cd` criadas
- [ ] **Execução de ensaio verde**: CI, depois CD disparando sozinho, e o app abrindo no Web App
- [ ] Aba **Tests** com 9 testes aprovados e artefato `drop` publicado

## 4. Código e repositório
- [ ] Arquivos de `projeto-java/` copiados para o projeto
- [ ] `webAppName` do `azure-pipelines-cd.yml` correto
- [ ] README preenchido (links, turma de cada integrante) e com o diagrama aparecendo
- [ ] Diagrama final com os **números de 1 a 10** nas setas e o cartão "Azure SQL Database"
- [ ] Nenhuma senha em nenhum arquivo do repositório
- [ ] `git push origin master` testado e **sem pedir login** (Git já autenticado)
- [ ] Título do Swagger no ar: `Clyvo VitalPet API` (base limpa). A mudança do vídeo é para `Clyvo VitalPet API v2`

## 5. Preparação da tela (abas e janelas abertas)
- [ ] IDE com o projeto aberto em `OpenApiConfig.java` e o terminal na pasta do projeto
- [ ] GitHub: página do repositório
- [ ] Azure DevOps: Overview do projeto, Users, Pipelines (lista), Library e Service connections
- [ ] Portal Azure: Resource Group e Web App (Overview e Deployment Center)
- [ ] Janela do `run.cmd` do agente
- [ ] Navegador: Swagger do Web App (`/swagger-ui.html`) e `/web/login`
- [ ] **Query editor** do Portal Azure (ou Azure Data Studio / SSMS) já conectado ao banco `vitalpet`
- [ ] Imagem do diagrama pronta para tela cheia
- [ ] Web App "acordado": abra a URL 1 minuto antes de gravar

## 6. Material pronto para colar
- [ ] JSON do POST de clínica (no roteiro, cena 13)
- [ ] JSON do PUT (nome `... ATUALIZADA` e telefone `11888880000`)
- [ ] Queries SQL em um arquivo aberto:
  ```sql
  SELECT id, nome, cnpj, telefone, ativa FROM clinicas ORDER BY id DESC;
  SELECT id, nome, cnpj, telefone, ativa FROM clinicas WHERE id = <ID>;
  SELECT version, description, success FROM flyway_schema_history;
  ```
- [ ] Roteiro impresso ou em um segundo monitor

## 7. Gravação e áudio
- [ ] Gravador de tela (OBS Studio) em **1920×1080, 30 fps**, mínimo 720p
- [ ] Microfone testado, **voz clara e sem eco**, sem legendas
- [ ] Zoom do navegador e da IDE em 125% a 150%, para ficar legível
- [ ] Notificações do Windows desligadas (Não Perturbe)
- [ ] PC **sem suspender** durante a gravação, com o carregador ligado
- [ ] Nenhuma senha, token ou e-mail pessoal visível (feche abas e arquivos sensíveis)
- [ ] Uma gravação de 20 segundos testada e assistida (imagem e áudio)

## 8. Durante a gravação (resumo do roteiro)
- [ ] Nome, RM e turma no início
- [ ] Descrição da solução e stack
- [ ] Diagrama explicado pelos números 1 a 10
- [ ] Ferramentas mostradas e professor com acesso Basic
- [ ] YAML do CI e do CD explicados, e variáveis com cadeado
- [ ] Alteração **no código**, commit e push na master
- [ ] CI e CD iniciando sozinhos, **com cada etapa explicada ao vivo e sem cortes**
- [ ] Artefato e testes mostrados
- [ ] Recursos atualizados no Portal Azure
- [ ] Aplicação com a alteração visível
- [ ] CRUD completo, com SELECT no banco a cada operação (explicar que o DELETE é lógico)

## 9. Depois de gravar
- [ ] Assistir ao vídeo inteiro (imagem legível e áudio ok)
- [ ] Subir no YouTube e abrir o link numa aba anônima
- [ ] Gerar o PDF **só com**: nome completo, RM e turma de cada integrante, link do GitHub, link do YouTube e link do projeto no Azure DevOps
- [ ] Confirmar o professor como Basic no projeto
- [ ] Entregar **antes de 04/11/2026**
- [ ] **Não apagar** os recursos da Azure até receber a nota (feedback em 11/11/2026)
- [ ] Revogar o token (PAT) do agente depois da entrega

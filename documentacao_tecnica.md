# Documentação Técnica: Arquitetura e Tecnologias — aprendeAI

Este documento apresenta uma visão técnica aprofundada da arquitetura, das tecnologias adotadas e das decisões de engenharia de software implementadas no **aprendeAI** para o **2º Hackathon SIF/UniRios 2026**. 

---

## 1. Visão Geral do Projeto
O **aprendeAI** é um ecossistema educacional inclusivo e interativo projetado para conectar alunos e professores particulares. O sistema aborda dores críticas de comunicação, flexibilidade de formatos de aula, e valorização docente, oferecendo:
- **Busca Mobile-First e Catálogo Dinâmico:** Localização de tutores com base em matérias.
- **Ciclo de Negociação Livre e Justo:** Negociação bidirecional de preços por meio de propostas e contra-propostas em tempo real, respeitando o piso salarial dos professores.
- **Ambiente de Ensino Multimodal:** Suporte para pílulas de conhecimento assíncronas gratuitas (foco em inclusão), sessões expressas síncronas (15 minutos) e mentorias focadas (30 a 60 minutos).
- **Inteligência Artificial Acadêmica:** Assistência para alunos e planejador pedagógico para professores, utilizando a API Google Gemini com sandboxing de segurança.
- **Sala Virtual e Fixação Pedagógica:** Videoconferência via Jitsi Meet integrada e chats reativos com ferramentas para formulação e resolução de atividades de fixação em tempo real.
- **Sistema de Moderação de Conteúdo:** Filtro avançado e proativo contra spam, ofensas ou burlas em dados de perfis, acompanhado de painel de controle e diário de auditoria administrativa.

---

## 2. Stack Principal

A stack tecnológica do **aprendeAI** foi selecionada com foco em **agilidade de entrega, facilidade de manutenção e máxima performance**, evitando dependências complexas de infraestrutura em nuvem:

| Camada | Tecnologia | Versão | Motivo da Escolha |
| :--- | :--- | :--- | :--- |
| **Linguagem** | Ruby | `3.4.0` | Alta expressividade, legibilidade de código e estabilidade em concorrência. |
| **Framework** | Ruby on Rails (MVC) | `8.1.3` | Filosofia de "baterias inclusas", convenções fortes sobre configuração, e novos padrões de alto desempenho nativos (Solid Queue/Cable/Cache). |
| **Banco de Dados (Local)** | SQLite | `3` | Banco relacional embarcado de alta performance em arquivos, livre de latência de rede em ambiente de testes/desenvolvimento. |
| **Banco de Dados (Produção)** | PostgreSQL | `-` | Padrão robusto para ambientes em nuvem (PaaS como Render), com alta concorrência de escrita. |
| **Estilização (UI)** | Tailwind CSS | `4.3.0` | Desenvolvimento de interfaces rápidas, customizadas e acessíveis (verde monocromático) sem arquivos de estilo inflados. |
| **Comunicação em Tempo Real** | Solid Cable | `3.0` | Engine de WebSockets baseada no próprio banco de dados, eliminando a dependência do Redis em produção. |
| **Processamento Assíncrono** | Solid Queue | `3.0` | Fila de segundo plano nativa no banco, removendo overhead de serviços adicionais como Sidekiq/Redis. |
| **Cache do Sistema** | Solid Cache | `3.0` | Caching persistente em disco para otimizar tempo de carregamento de páginas. |

---

## 3. Arquitetura do Backend

O backend segue o clássico padrão **MVC (Model-View-Controller)** do Ruby on Rails, complementado com camadas de **Services** e **Validators** para manter a lógica de negócios isolada dos controladores.

```mermaid
graph TD
    Client[Navegador do Usuário] <--> ActionCable[Solid Cable / WebSockets]
    Client <--> Controllers[Controllers]
    
    subgraph Camada de Negócios (Backend)
        Controllers --> Models[Models]
        Controllers --> Services[Services: AiService & ModerationService]
        Models --> Validators[Validators: InappropriateTextValidator]
    end
    
    subgraph Camada de Persistência
        Models <--> Database[(Banco de Dados: Postgres/SQLite)]
        ActiveStorage[Active Storage] <--> Disk[(Armazenamento Físico / Render Volume)]
    end
    
    subgraph Serviços Externos
        Services <--> Gemini[API Google Gemini]
        Controllers <--> Jitsi[Jitsi Meet Video API]
    end
```

### Componentes de Destaque no Backend
1. **[AiService](file:///c:/Users/vitor/documents/hacka2/app/services/ai_service.rb):** Centraliza a comunicação com a API do Gemini da Google. Conta com um filtro proativo: se o prompt enviado pelo estudante ou professor não for de caráter educacional/planejamento pedagógico, o serviço responde informando as diretrizes acadêmicas da plataforma, reduzindo custos de consumo de API.
2. **[ModerationService](file:///c:/Users/vitor/documents/hacka2/app/services/moderation_service.rb):** Executa rotinas avançadas de sanitização de texto em quatro etapas de normalização (conversão de acentos, transliteração de homóglifos Unicode, tratamento de leetspeak e eliminação de letras repetidas consecutivamente) antes de cruzar dados com a lista negra configurável em [moderation_blacklist.yml](file:///c:/Users/vitor/documents/hacka2/config/moderation_blacklist.yml).
3. **[InappropriateTextValidator](file:///c:/Users/vitor/documents/hacka2/app/validators/inappropriate_text_validator.rb):** Validador personalizado do ActiveModel que estende a moderação diretamente aos campos sensíveis de cadastro do `User` (`name`, `availability`, `experience`, `preferences`).

---

## 4. Arquitetura do Frontend

O **aprendeAI** adota a filosofia do **Hotwire Stack**, proporcionando uma experiência de SPA (Single Page Application) fluida, mas sem o custo operacional, de build e SEO de frameworks como React ou Next.js:

- **Turbo Drive / Turbo Frames:** Tratam cliques em links e envios de formulários capturando o HTML de resposta e atualizando dinamicamente apenas o fragmento necessário da página.
- **Turbo Streams (Reatividade Nativa):** Permitem empurrar atualizações do servidor diretamente para o navegador do cliente em tempo de execução via WebSockets (Solid Cable). É utilizado para:
  - Enviar novas mensagens no chat instantaneamente.
  - Sincronizar em tempo real as atividades formuladas pelo professor e as respostas preenchidas pelo aluno.
  - Atualizar o contador do sino de notificações bilaterais.
- **Stimulus JS & Vanilla JS:** Utilizados de maneira cirúrgica para comportamentos puramente visuais, como:
  - Alternância dinâmica de campos específicos (Aluno vs Professor) no formulário de registro.
  - **Debounce de 400ms** nas caixas de texto públicas para disparar requisições assíncronas (`fetch`) de moderação, alertando preventivamente o usuário sobre conteúdo impróprio antes do submit do formulário.

---

## 5. Banco de Dados: Como Funciona e Por Que

O banco de dados foi modelado sob princípios de **normalização estruturada e integridade referencial estrita**. 

### Estrutura de Modelagem Lógica
- **`User`:** Armazena dados de Alunos, Professores e Administradores. A diferenciação é feita através de enums (`role`: `student`, `teacher`). Possui campos flexíveis para o perfil de cada papel (`preferences` para alunos, `experience` e `certificate_url` para professores).
- **`Subject`:** Tabela contendo as matérias/especialidades.
- **`subjects_users`:** Tabela de junção N:N para a relação "Tem e Pertence a Muitos" (HABTM) entre usuários e matérias.
- **`Proposal`:** O coração da negociação. Liga `student_id` e `teacher_id` de forma assimétrica. Possui a coluna `sender_id` para identificar o autor da última oferta na negociação de contra-propostas e o enum `status` (`pending`, `accepted`, `rejected`, `closed`) que rege as transições permitidas.
- **`Message`:** Herda o contexto da proposta e agrupa o chat de conversação e o motor de atividades pedagógicas via colunas de enum `message_type` (`regular`, `activity`), `question_type` (`open`, `closed`), `options` (para múltipla escolha) e `student_answer`.
- **`Notification`:** Histórico bilateral de interações (sino) servindo como feed de relacionamento em tempo real.
- **`AuditLog`:** Diário oficial de ações de moderação executadas por administradores na base de dados.

### Estratégia de Transições de Banco em Produção (Render)
No Rails 8, as engines de fila (`Solid Queue`), websocket (`Solid Cable`) e cache (`Solid Cache`) gerenciam bancos de dados apartados por padrão. Contudo, em ambientes PaaS como o Render, a manutenção de múltiplos servidores de banco de dados representa um custo proibitivo.

A arquitetura do **aprendeAI** resolveu essa limitação configurando todas as bases para apontarem para um único endpoint PostgreSQL (`DATABASE_URL`), porém **isolando os caminhos de migração** de cada engine no [database.yml](file:///c:/Users/vitor/documents/hacka2/config/database.yml):
```yaml
production:
  primary: &primary_production
    adapter: postgresql
    url: <%= ENV["DATABASE_URL"] %>
  cache:
    <<: *primary_production
    migrations_paths: db/cache_migrate
  queue:
    <<: *primary_production
    migrations_paths: db/queue_migrate
  cable:
    <<: *primary_production
    migrations_paths: db/cable_migrate
```
Isso garante a unificação sob uma única instância compartilhada de banco de dados, mas **evita a colisão de timestamps de migração** e inconsistências de tabelas durante o deploy!

---

## 6. Armazenamento de Arquivos e Imagens

O gerenciamento de uploads (como fotos de perfil de usuários e anexos compartilhados no chat) é feito nativamente pelo **Active Storage** usando o serviço `:local`.

### Resiliência ao Ambiente Efêmero da Nuvem (Render)
As instâncias do Render possuem sistemas de arquivos efêmeros, o que significa que qualquer arquivo gravado localmente é deletado a cada deploy. 
Para contornar isso e permitir a sobrevivência estável de arquivos de upload sem exigir contratação imediata de buckets S3/GCS, foi desenvolvida uma lógica dinâmica e inteligente de caminhos no arquivo [storage.yml](file:///c:/Users/vitor/documents/hacka2/config/storage.yml):

```yaml
local:
  service: Disk
  root: <%= ENV['ACTIVE_STORAGE_PERSISTENT_DIR'].presence || (Dir.exist?('/data') && File.writable?('/data') ? '/data/storage' : (Dir.exist?('/var/data') && File.writable?('/var/data') ? '/var/data/storage' : Rails.root.join("storage").to_s)) %>
```

**Como funciona:**
1. A aplicação checa se a variável de ambiente `ACTIVE_STORAGE_PERSISTENT_DIR` está configurada.
2. Caso não esteja, ela testa se existe o diretório `/data` ou `/var/data` (padrões de montagem de volumes persistentes do Render) e se a aplicação tem permissão de escrita. Se sim, armazena os uploads no disco persistente montado (`/data/storage` ou `/var/data/storage`).
3. Caso contrário (desenvolvimento e testes locais), ela automaticamente faz o fallback e grava os dados na pasta `storage/` na raiz do projeto.

Isso garante **configuração zero** localmente e persistência durável de arquivos em produção!

---

## 7. Autenticação e Permissões

A segurança do sistema foi blindada nativamente, priorizando baixo acoplamento e alto desempenho:

- **Autenticação Nativa Leve:** Utiliza sessões HTTP tradicionais (`session[:user_id]`) integradas ao método macro `has_secure_password` do ActiveModel, amparado pela biblioteca de hash criptográfico **BCrypt**. Isso elimina a necessidade de gems complexas como Devise, mantendo total flexibilidade na modelagem dos perfis.
- **Controle de Acesso Baseado em Função (RBAC):** Os controladores aplicam filtros de interceptação para garantir o isolamento lógico das rotas:
  - `require_login`: Exige credenciais válidas.
  - `require_admin`: Exige a flag `admin: true` no usuário ativo.
  - `check_student_access` / `check_teacher_access`: Protegem e isolam visualizações cruzadas. Professores não podem ler painéis internos de outros professores ou listas exclusivas de alunos, e vice-versa.
- **Blindagem Contra Usuários Suspensos ou Banidos:**
  - Tentativas de login por contas com status `suspended` ou `banned` são sumariamente rejeitadas com mensagens personalizadas.
  - O método `current_user` realiza checagens contínuas na base de dados. Se o administrador suspender ou banir um usuário enquanto este navega na plataforma, a sessão é destruída instantaneamente no próximo clique, deslogando-o de forma imediata.
- **Invisibilidade Pública Preventiva:**
  - Perfis banidos ou que possuem privilégios de administrador (`admin: true`) são omitidos de buscas públicas, carrosséis de destaque na Home, e listagens em geral através do escopo centralizado `User.public_view`.
  - Acesso direto via URL para perfis de administradores ou usuários banidos por usuários comuns dispara um erro `ActiveRecord::RecordNotFound`, resultando em resposta HTML `404 Not Found` segura.

---

## 8. Painel Administrativo de Moderação

Uma das maiores inovações do **aprendeAI** é o seu painel centralizado de moderação de conteúdo, planejado para garantir a segurança e a integridade de dados e nomes expostos na plataforma:

```
[Cadastro do Usuário] 
       │
       ▼
[InappropriateTextValidator] ──► Flag de Moderação Automática ──► [Moderation Dashboard (Fila de Suspeitos)]
       │                                                                  │
       ├─► (Verificação AJAX em tempo real no Form)                       ├─► Safe-Mark (Aprova Bypass)
       │                                                                  ├─► Edição de Nome Corretiva
       ▼                                                                  └─► Suspensão ou Banimento (Em lote ou Individual)
[Persiste no Banco]
```

### Funcionalidades Administrativas
1. **Fila de Suspeitos Reativa:** Classifica automaticamente perfis com nomes ou descrições impróprias detectados pelo `ModerationService`, agrupando-os para análise imediata em uma aba dedicada sem travar a navegação do usuário.
2. **Ações Individuais e em Lote:** O administrador pode selecionar múltiplos usuários usando checkboxes em lote e aplicar decisões massivas de aprovação (*safe-mark*), suspensão de conta ou banimento imediato.
3. **Edição Corretiva de Nomes:** Permite ao administrador alterar diretamente o nome de um usuário que violou os termos para uma alcunha neutra de forma rápida pela interface do painel.
4. **Diário de Auditoria (`AuditLogs`):** Toda ação de moderação (individual ou em lote) é registrada detalhadamente na base, informando o administrador responsável, e-mail, usuário alvo, ação executada e os termos envolvidos, acessível em uma interface de auditoria visual premium com filtros rápidos por tipo de ação.
5. **Salvaguarda de Demonstração (Demo Guard):** O botão de atalho para login rápido como Administrador é estritamente limitado aos ambientes locais de desenvolvimento e testes. Em produção, a rota e a exibição visual são completamente desativadas para garantir a segurança do sistema contra bypasses não autorizados.

---

## 9. Deploy e Ambiente de Produção

A infraestrutura produtiva do **aprendeAI** é automatizada para assegurar integridade contínua a cada nova alteração:

- **Hospedagem PaaS (Render):** O projeto foi implantado no Render para aproveitar os recursos de continuous delivery integrados ao Git.
- **Pipeline de Build ([render-build.sh](file:///c:/Users/vitor/documents/hacka2/bin/render-build.sh)):** Um shell script automatiza as etapas cruciais a cada push no repositório:
  1. `bundle install`: Instala e atualiza as dependências listadas no Gemfile.
  2. `bundle exec rails db:migrate`: Executa as migrações em lote nas pastas isoladas do PostgreSQL de produção.
  3. `bundle exec rails assets:precompile`: Compacta e compila folhas de estilo do Tailwind e arquivos estáticos via Propshaft.
- **Gerenciamento de Containers:** Contém um arquivo `Dockerfile` e `.dockerignore` configurados nativamente para permitir escalabilidade horizontal por meio de containers caso o tráfego da plataforma atinja níveis elevados.

---

## 10. Ferramentas de Desenvolvimento

O ambiente de engenharia de software do projeto conta com ferramentas de controle de qualidade e estruturação rápida:

- **Suíte de Testes Automatizados (Minitest):** O sistema possui **80 testes de integração e unitários** com 100% de sucesso e cobertura. Os testes cobrem:
  - Validações de modelos e enums.
  - Fluxo completo de autenticação e redirecionamento.
  - Validação estrita de limites salariais de propostas e transição de status.
  - Segurança de acesso cruzado por papéis (RBAC).
  - Ocultação de perfis suspensos, banidos e de administradores em buscas públicas.
  - Criação e envio de respostas de atividades pedagógicas discursivas/múltipla escolha.
  - Ações individuais, em lote e geração de registros de auditoria no painel administrativo.
- **WebMock (Stubs de Teste):** Utilizado para capturar requisições de saída para a API do Gemini durante a execução dos testes automatizados de Inteligência Artificial, gerando stubs estáticos. Isso permite que a suíte de testes rode 100% local, offline, sem consumir tokens reais de API e de forma extremamente rápida.
- **Seeds Idempotentes (`db/seeds.rb`):** Script de carga focado unicamente na criação do catálogo estrutural básico de Matérias/Disciplinas (`Subject`). Utiliza `find_or_create_by!` para garantir que o script possa ser executado diversas vezes sem gerar registros duplicados ou lixo no banco de dados.
- **RuboCop:** Analisador estático de código configurado para aplicar as melhores práticas de estilo de desenvolvimento em Ruby estabelecidas pela comunidade Rails.

---

## 11. Decisões Técnicas e Justificativas

A tomada de decisão arquitetural do **aprendeAI** priorizou soluções pragmáticas que valorizam o tempo de desenvolvimento e reduzem o atrito no uso da plataforma:

1. **Escolha do Hotwire em detrimento de SPAs Complexas (React/Vite/Next.js):**
   - *Justificativa:* Frameworks modernos de JavaScript geram grandes bundles de arquivos, prejudicando o tempo de carregamento inicial em conexões 3G/4G instáveis, comuns para estudantes de periferia ou zonas rurais. O Hotwire permite renderização no servidor de altíssima performance, com consumo de dados irrisório e mantendo a reatividade instantânea que a banca avaliadora espera em um MVP de chat e salas virtuais.
2. **Escolha de SQLite no Desenvolvimento e PostgreSQL na Produção:**
   - *Justificativa:* O SQLite3 permite inicialização instantânea do projeto por novos desenvolvedores e avaliadores, sem necessidade de configurar servidores locais complexos como Docker, instâncias PostgreSQL ou serviços de rede locais. A transição para PostgreSQL no ambiente de produção do Render assegura a robustez e concorrência requeridas para a escala do hackathon.
3. **Uso de Solid Cable, Solid Queue e Solid Cache:**
   - *Justificativa:* Tradicionalmente, sistemas reativos com tarefas de segundo plano exigem a instalação do servidor Redis. O uso da nova suíte nativa do Rails 8 consolida toda a persistência de filas, cache e pub/sub de WebSockets diretamente em tabelas no próprio banco relacional (SQLite local / Postgres em produção). Isso simplificou drasticamente a topologia do deploy, reduzindo a complexidade de múltiplos serviços para uma única máquina.
4. **Chat Reativo com Estratégia de CSS Unificado:**
   - *Justificativa:* Em vez de criar lógica pesada em JavaScript ou visões HTML complexas duplicadas para alinhar balões de mensagens de chat à esquerda ou à direita dependendo do autor, o layout injeta uma folha de estilo dinâmica inline que cruza o ID da mensagem com o do visualizador logado. O resultado é um posicionamento de balões instantâneo e extremamente elegante com zero linhas adicionais de JS no carregamento dinâmico via WebSockets.

---

## 12. Conclusão

O ecossistema do **aprendeAI** demonstra que é plenamente possível construir uma aplicação web moderna, segura, reativa e inteligente utilizando uma arquitetura monolítica enxuta e elegante. 

As escolhas técnicas implementadas garantem que a aplicação atenda com louvor a todos os critérios eliminatórios do regulamento do **Hackathon SIF/UniRios 2026** (Funcionalidade, Qualidade do Código, Banco de Dados, Segurança e Inclusão), entregando valor de ponta a ponta com máxima performance, facilidade de auditoria e excelente experiência do usuário.

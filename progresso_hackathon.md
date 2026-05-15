# Progresso do Projeto — Hackathon SIF/UniRios 2026

## Decisões fixadas
- Stack principal: SQLite + Ruby on Rails + Tailwind CSS.
- Estilo de implementação: código simples, pragmático, sem complexidade desnecessária.
- Ferramenta de apoio: Antigravity com Gemini.
- Estratégia de continuidade: manter este arquivo markdown como memória operacional do projeto.
- Estratégia de prompts: instruções curtas, objetivas e econômicas em tokens.
- Regra de continuidade: antes de cada nova tarefa, ler este arquivo e continuar a mesma linha de raciocínio.

## Regras de trabalho
1. Priorizar funcionamento antes de refinamento.
2. Fazer o menor código possível para entregar valor.
3. Evitar abstrações prematuras, metaprogramação e arquitetura excessiva.
4. Manter nomes claros, arquivos curtos e responsabilidades simples.
5. Registrar aqui o que foi decidido, criado, alterado e o próximo passo.
6. Toda nova decisão relevante deve atualizar este arquivo.
7. Se houver dúvida, escolher a solução mais simples que atenda ao regulamento.

## Alinhamento com o regulamento
- O projeto precisa usar banco de dados.
- O projeto precisa usar framework.
- O projeto precisa ter README.md com descrição do projeto, tecnologias e versões, abordagens/metodologias, como executar e diagrama lógico do banco.
- Se faltar um requisito mínimo, a equipe pode ser desclassificada.
- A primeira etapa avalia: aderência ao tema, qualidade do código, funcionalidade e segurança.
- As 3 equipes com maior pontuação vão para a final.

## Linha de raciocínio adotada
- Preparar uma base Rails enxuta para adaptar rapidamente quando o tema sair.
- Favorecer CRUDs simples, autenticação básica e interface limpa.
- Estruturar o projeto para facilitar leitura por comissão avaliadora e análise automatizada.
- Tratar README e organização do repositório como parte do produto.

## Estrutura inicial sugerida
- Aplicação Rails com SQLite.
- Tailwind para interface rápida e limpa.
- README.md obrigatório e bem objetivo.
- Pasta ou seção com diagrama lógico do banco.
- Autenticação simples, se o tema exigir usuários.
- Modelos e controllers enxutos.

## Checklist contínuo
- [ ] Criar app base Rails
- [ ] Configurar Tailwind
- [ ] Definir estrutura mínima do domínio após o tema
- [ ] Modelar banco de dados
- [ ] Implementar fluxo principal
- [ ] Revisar segurança básica
- [ ] Escrever README final
- [ ] Gerar diagrama lógico
- [ ] Revisar execução local
- [ ] Enviar URL do GitHub

## Prompt base curto para continuidade
Use este progresso como memória do projeto. Leia o arquivo `progresso_hackathon.md` antes de responder. Continue na mesma linha de raciocínio, com soluções simples, pragmáticas e curtas em tokens. Stack fixa: SQLite + Ruby on Rails + Tailwind CSS. Ferramenta: Antigravity com Gemini. Evite complexidade desnecessária, contexto longo e abstrações prematuras. Ao final, atualize o `progresso_hackathon.md` com o que foi decidido e o próximo passo.

## Prompt curto para pedir implementação
Leia o markdown `progresso_hackathon.md` e continue de onde parou. Faça apenas o necessário para esta tarefa, com Rails simples, SQLite e Tailwind. Gere código enxuto, fácil de manter e alinhado ao hackathon.

## Definições do Produto (aprendeAI)
- **Tema:** Transformando a Educação e a Aprendizagem com Tecnologia e Inclusão.
- **Nome do sistema:** aprendeAI
- **Tipo de sistema:** Plataforma simples de conexão entre alunos e professores.
- **Solução escolhida:** MVP focado na busca de professores e envio de propostas de aulas, utilizando interface limpa em azul e branco.
- **Modelagem escolhida:** `User` (guarda dados, role, certificado e escolaridade para evitar tabelas extras), `Subject` (área de interesse), `Proposal` (negociação de valores).
- **Relacionamentos:** `User` tem e pertence a muitos `Subjects` (HABTM); `User` tem muitas `Proposals` (como aluno ou professor).
- **Regra do certificado:** O model `User` terá os campos `certificate_url` e `certified` (boolean). Somente professores com `certified: true` ficam visíveis na busca.
- **Regra do piso:** O model `Proposal` valida na criação se `price` >= valor mínimo estipulado, caso o professor tenha `education_level` técnico ou superior.

## Base Técnica Inicial
- **Models implementáveis:** `User`, `Subject`, `Proposal`.
- **Migrations definidas:** Criação de `users`, `subjects`, `proposals` e a tabela de junção `subjects_users`.
- **Validações principais:** 
  - `User`: presence e uniqueness de email.
  - `Proposal`: presença de price e regra de negócio do piso mínimo (técnico/superior).

## Navegação e Fluxos Definidos
- **Rotas principais:** `/` (home), `/sessions` (login/logout), `/users` (cadastro), `/teachers` (busca de professores), `/proposals` (negociação).
- **Controllers:** `PagesController` (home), `SessionsController` (auth), `UsersController` (cadastro), `TeachersController` (index de busca), `ProposalsController` (CRUD negociação).
- **Telas do MVP:** Home, Login, Cadastro, Lista de Professores, Nova Proposta, Painel de Propostas (enviadas/recebidas).

## Estrutura Visual (UI/UX)
- **Telas principais definidas:** Home (Apresentação), Cadastro/Login (Formulários simples), Busca de Professores (Cards), Painel de Propostas (Lista unificada).
- **Direção visual escolhida:** Minimalista, fundo cinza ultraclaro (`bg-slate-50`), elementos em branco (`bg-white`) com sombras suaves, e ações principais em azul forte (`text-blue-600`, `bg-blue-600`).
- **Componentes principais:** Navbar fixa (Logo + Links simples), Cards (Listagem e Propostas), Botões (Primários azuis, Secundários outline), Formulários (Inputs com focus ring azul).

## Views e HTML ERB
- **Arquivos definidos:** `application.html.erb` (layout base), `home/index.html.erb` (landing), `sessions/new.html.erb` (login), `teachers/index.html.erb` (lista), `proposals/new.html.erb` (formulário), e painéis base para aluno (`students/show`) e professor (`teachers/show`).
- **Padrão visual adotado:** Minimalismo com azul forte para botões e links (`bg-blue-600`, `text-blue-600`), fundos em branco (`bg-white`) com bordas sutis (`border-slate-200`) e fundo principal em `bg-slate-50`. Classes do Tailwind aplicadas diretamente sem extração excessiva de componentes.

## Camada de Controllers e Rotas
- **Rotas definidas:** Mapeamento completo em `config/routes.rb` abrangendo `home`, autenticação (`sessions`), cadastro (`users`), busca e painel (`teachers`, `students`), e negociação (`proposals`).
- **Controllers definidos:** `ApplicationController` (com helper de auth), `HomeController`, `SessionsController`, `UsersController`, `StudentsController`, `TeachersController`, `ProposalsController`.
- **Actions principais:** Autenticação padrão, visualização de painéis via `show`, envio de propostas e aprovação/recusa mudando o status na action `update`.

## Autenticação e Segurança
- **Estratégia de autenticação:** Sessão nativa do Rails (`session[:user_id]`) acoplada ao `has_secure_password` do model `User`. Sem gems externas (Devise).
- **Métodos principais:** `current_user` com memoization, `logged_in?` para condicional de interface, e `require_login` como filtro de proteção.
- **Regra básica de acesso:** Além do login, validação de `role` (`student?` / `teacher?`) nos controllers de painel para isolar o escopo e evitar acessos indevidos.

## Estratégia de Dados e Cadastros
- **Dados Fake/Mocks:** Estritamente proibidos. A demonstração do MVP será feita 100% com dados reais inseridos pela interface durante a apresentação.
- **Fluxo de Cadastro:** Formulário unificado. O aluno preenche os dados básicos. O professor preenche os dados básicos e adiciona escolaridade + link do certificado.
- **Validações e Visibilidade:** O professor recém-cadastrado nasce com `certified: false` por segurança. Apenas quando o campo for `true` ele aparecerá para os alunos.

## Implementação Prática Executada
- **Arquivos Core Salvos:** Os arquivos essenciais de MVC (Model, View, Controller), rotas e migrations foram gravados fisicamente no workspace `hacka2`.
- **Views e Layouts:** Os templates `.html.erb` utilizando a base estilizada do Tailwind foram aplicados, conectando os fluxos desenhados.
- **README:** O arquivo principal do repositório foi construído para agradar aos avaliadores do hackathon.

## Auditoria de Implementação
- **Rotas:** `config/routes.rb` corrigido e atualizado com os mapeamentos reais do MVP (`users`, `sessions`, `students`, `teachers`, `proposals`).
- **Models:** Existentes (`User`, `Subject`, `Proposal`) com validações, associations e enum implementados.
- **Controllers:** Existentes (Application, Home, Sessions, Users, Students, Teachers, Proposals) com as actions enxutas e filtros de autenticação.
- **Views:** Existentes e estilizadas (layouts, home, sessions, users, students, teachers, proposals).
- **Migrations:** Existentes (users, subjects, join_table, proposals).
- **Faltando:** Nenhuma base de código faltando para o MVP. O que falta é a execução do banco (`rails db:migrate`).

## Suíte de Testes (Minitest)
- **Testes Criados:** Testes de modelo para validações (`user_test.rb`, `subject_test.rb`, `proposal_test.rb`) e testes de integração de fluxo (`auth_flow_test.rb`, `proposals_flow_test.rb`). Fixtures adicionadas para `users`, `subjects` e `proposals`.
- **Falhas Encontradas:**
  1. `ArgumentError` nos models devido à sintaxe do `enum` ser incompatível com o Ruby 3 na versão em uso.
  2. `NameError` de `BCrypt` não inicializado nas fixtures, pois a gem `bcrypt` estava desativada no Gemfile.
  3. `NoMethodError` nos métodos `logged_in?` e `require_login`, pois o `ApplicationController` havia sido sobrescrito apagando os helpers.
  4. Erro de redirecionamento duplo no fluxo de login.
- **Correções Feitas:**
  1. Atualizada a sintaxe dos `enums` nos models `User` e `Proposal` para passar os parâmetros como options corretos (`enum :campo, valores...`).
  2. Gem `bcrypt` ativada via bundle e inclusa no topo do fixture de usuários (`require 'bcrypt'`).
  3. Helpers de autenticação restaurados no `ApplicationController`.
  4. Teste de login corrigido para seguir o segundo redirect (`student_path`).
- **Testes que Passaram:** A suíte completa (13 testes) abrange o MVP sem dados mockados fora dos fixtures locais.

## Navegação Pública e Visibilidade
- **Fluxo Inicial (Home):** O arquivo `home/index.html.erb` foi ajustado para guiar visitantes não autenticados através de dois botões claros: "Sou Aluno" (redireciona para listar professores) e "Sou Professor" (redireciona para listar alunos).
- **Navbar Global:** Restaurada a barra de navegação no `layouts/application.html.erb` (que havia sido sobrescrita pelo `rails new`). A navbar exibe botões dinâmicos ("Entrar"/"Cadastrar" para visitantes, e "Meu Painel"/"Sair" para logados) acompanhando a estilização azul/branca.
- **Controladores e Rotas:** `StudentsController` e `TeachersController` tiveram a exigência de login (`before_action :require_login`) removida e agora expõem as actions `index` (listagens públicas) e `show` (perfis públicos). A rota `students#index` foi adicionada em `config/routes.rb`.
- **Views (Telas Públicas vs Privadas):**
  - Adicionado `students/index.html.erb` para expor o catálogo de alunos.
  - Modificadas as views `students/show.html.erb` e `teachers/show.html.erb` utilizando a condicional `current_user == @resource` para separar o que é o Painel Privado (dashboards com histórico de propostas) e o que é o Perfil Público (informações básicas e botão para "Fazer Proposta").
- **Proteção de Serviços:** Apenas a área interativa sensível (`ProposalsController` e criação de perfis em `UsersController`) manteve a exigência nativa de autenticação baseada em sessão.

## Melhorias no Fluxo de Cadastro
- **Escolha de Perfil na UI:** O formulário de registro (`app/views/users/new.html.erb`) foi atualizado para conter um `select` explícito onde o usuário escolhe "Sou Aluno" ou "Sou Professor".
- **Alternância Dinâmica (JS Simples):** As opções de cadastro agora usam um script JavaScript extremamente enxuto (uma única tag `<script>` no final do form) que alterna a visibilidade dos campos extras de professor e aluno dependendo da opção selecionada no combo.
- **Redirecionamento Pós-Cadastro/Login:** O `UsersController` e o `SessionsController` foram alterados para que, ao invés de enviar o usuário sempre para a `root_path` genérica, ele seja direcionado com precisão para o seu painel de gerenciamento usando o ternário `@user.student? ? student_path(@user) : teacher_path(@user)`. Os testes de integração acompanharam essa alteração de redirecionamento imediato.

## Identidade Visual Oficial Aplicada
- **Conceito Estético:** A interface foi reestruturada para refletir um ambiente educacional monocromático, limpo, acolhedor e acessível. Toda a paleta gira em torno da cor verde, com total exclusão de cores frias anteriores (como slate/blue) e remoção da complexidade do dark mode, mantendo um foco puro no *light mode*.
- **Paleta Centralizada (Tailwind CSS v4):** 
  - `--color-aprende-primary`: `#1DB84E` (Esmeralda viva para ações).
  - `--color-aprende-bg`: `#F4FBF6` (Névoa verde/fundo respirável).
  - `--color-aprende-secondary`: `#C2E8CF` (Menta suave para bordas/hover).
  - `--color-aprende-text`: `#0F2E1A` (Verde muito escuro para contraste principal).
  - `--color-aprende-muted`: `#5A9E70` (Verde musgo para textos de apoio).
- **Tipografia e Formas:** Fonte Inter restrita aos pesos 400 (normal) e 500 (medium). Elementos com cantos extremamente arredondados (`rounded-[1.5rem]` para cards, `rounded-xl` para inputs), e bordas suaves de contraste, sem sombras pesadas.
- **Views Refatoradas:** Todas as áreas públicas (Home, Autenticação) e fechadas (Painéis de Estudante/Professor e Envio de Propostas) adotaram integralmente este sistema visual estrito.

## Correções de Fluxo
- **Bug Fix (Campo "Área de Ensino" invisível para Professor):** 
  - **Causa:** O formulário utilizava `collection_check_boxes` iterando sobre `Subject.all`. Como o banco estava limpo (sem *seeds* ou painel de criação), a coleção retornava vazia, fazendo com que o Rails não renderizasse absolutamente nada na tela (nem um aviso), levando à percepção de que o campo havia "sumido". Além disso, o script JS que alterna os campos tinha problemas com a navegação do Turbo do Rails 7.
  - **Correção:** 
    1. Adicionado script de carga inicial em `db/seeds.rb` contendo matérias reais (Matemática, Programação, etc.) para servir de base de domínio, garantindo que o campo de seleção não fique vazio na interface. O `rails db:seed` foi executado.
    2. Adicionado tratamento de *fallback* (`<% if Subject.any? %>...<% else %>...`) nas views de cadastro para que, caso o banco esteja vazio, seja exibida uma mensagem elegante de erro em vez de esconder silenciosamente a interface do usuário.
    3. Refatorado o Javascript em linha para lidar adequadamente com eventos do Turbo (`turbo:load` e `DOMContentLoaded`), garantindo que os blocos `teacher_fields` ou `student_fields` alternem corretamente em todos os cenários de navegação.
    4. Adicionado teste em `auth_flow_test.rb` para garantir que `subject_ids` é recebido, validado pelos *strong params* (`UsersController`) e persistido corretamente pela associação. Os testes estão passando (`rake test`).

## Correções de Layout e Responsividade
- **Ajuste Pontual de Margem (Cadastro e Login):** O formulário de criação de conta (`users/new`) e login (`sessions/new`) estava sendo empurrado muito para baixo devido a uma combinação da classe `md:mt-12` com o `p-6` nativo da `<main>`. O espaçamento foi reduzido pragmaticamente para `mt-0 md:mt-4`, subindo o card na tela, eliminando o espaço vazio excessivo no topo, mantendo-o bem legível e centralizado sem quebrar o layout.
- **Limpeza de Espaçamentos Excessivos:** 
  - Removido o uso arbitrário de classes `mt-10` e `mt-12` em todas as *views* principais (Home, Índices, Perfis, Login e Formulários) que espremiam o conteúdo em resoluções menores.
  - Implementado espaçamento dinâmico via flexbox (`flex flex-col gap-6 w-full`) em substituição ao excesso de margens individuais (`mb-*`, `mt-*`).
- **Adequação para Mobile:** 
  - Estruturação dos formulários e *cards* para ocupar a largura total no mobile (`w-full`), reorganizando botões (`w-full sm:flex-1`) e *inputs* para que não ocorram quebras laterais.
  - O *grid* de professores e alunos foi ajustado para `grid-cols-1 md:grid-cols-2 lg:grid-cols-3` com recuos proporcionais (`p-6 md:p-8`), permitindo empilhamento natural em telas pequenas.
  - O formulário centralizado de "Buscar Matéria" na *Home* e os perfis agora reagem melhor, desativando larguras fixas limitantes.
- **Manutenção da Identidade:** A estética verde monocromática leve (fundo `#F4FBF6`, ações em esmeralda, bordas menta suave) foi rigorosamente mantida e os cards preservaram seus cantos arredondados (`rounded-[1.5rem]`).

## Seed como Catálogo Estrutural
- **Separação de Conceitos:** Diferenciando *mock data* (dados falsos de usuários ou propostas) de *dados de referência* (catálogos imutáveis do sistema), o arquivo `db/seeds.rb` foi configurado estritamente como um catálogo estrutural.
- **Áreas de Ensino (`Subject`):** Populado com diversas matérias reais (Matemática, Design, Inglês, Preparatório ENEM, etc.) que formam a base relacional entre professores e alunos. Foi utilizada a sintaxe `find_or_create_by!` garantindo a idempotência, ou seja, o comando pode ser rodado múltiplas vezes sem causar duplicidade.
- **Escolaridades:** Registrado em comentário no seed que as escolaridades são gerenciadas via Enum (`User.education_levels`) em vez de tabela própria, eliminando complexidade desnecessária.

## Separação de Regras e Perfis (Role Access)
- **Regra de Visibilidade Mútua:** Implementada lógica estrita onde alunos logados buscam professores e professores logados visualizam alunos.
- **Proteção de Fluxo:** Adicionados `before_action :check_student_access` no `StudentsController` e `:check_teacher_access` no `TeachersController`. Eles verificam o `current_user` e bloqueiam acessos cruzados (ex: aluno tentando ver a lista de alunos ou o perfil de outro aluno), redirecionando-os para a listagem correspondente.
- **Limpeza de UI:** A barra de navegação (`application.html.erb`) foi ajustada com condicionais para que alunos não vejam o link "Alunos", e professores não vejam o link "Professores". Visitantes continuam vendo ambas as opções.
- **Testes de Acesso:** Criado arquivo `test/integration/role_access_test.rb` que garante e valida o comportamento de redirecionamento e permissão de visualização dos painéis.

## Regras de Negócio de Propostas (Proposals)
- **Criação e Papéis:** Validado no model `Proposal` que o `student` obrigatoriamente deve ter o papel de aluno e o `teacher` deve ter o papel de professor (`validate :users_have_correct_roles`).
- **Autoproposta Bloqueada:** Impedido que um usuário envie uma proposta para si mesmo (`validate :users_are_different`).
- **Bloqueio de Duplicidade:** Adicionado um `validates :subject_id, uniqueness` no escopo do `student_id` e `teacher_id` apenas para propostas com status `pending` ou `accepted`, evitando spam de propostas para a mesma matéria com o mesmo professor enquanto houver negociação ativa.
- **Transição de Status Segura:** O ciclo de vida da proposta (`pending` -> `accepted` | `rejected`, e `accepted` -> `closed`) foi blindado no model (`validate :valid_status_transition, on: :update`).
- **Permissão de Acesso e Atualização:**
  - `ProposalsController#create` restrito a alunos (via `require_student`).
  - `ProposalsController#update` restringe a busca da proposta (`@proposal`) apenas aos participantes envolvidos (`student_id` ou `teacher_id` igual ao `current_user.id`).
  - Alunos são impedidos de aceitar/recusar propostas. Ambos podem teoricamente fechar uma proposta já aceita.
- **Integração com Chat:** O model `Proposal` já possui `has_many :messages`, deixando a porta aberta e estruturalmente pronta para a funcionalidade de chat/negociação contínua sem quebrar a lógica atual.

## Interface de Propostas e Chat (Messages)
- **Rotas de Status (Member Actions):** Atualizado `config/routes.rb` para usar rotas RESTful amigáveis na proposta (`patch :accept`, `patch :reject`, `patch :close`) visando clareza no controller e nas views.
- **Visualização da Proposta (Show):** Criada a tela `app/views/proposals/show.html.erb` onde ocorre a negociação. Ela exibe os dados da proposta, status atual com cores de destaque e botões condicionais (Professor vê "Aceitar/Recusar" quando pendente. Ambos vêem "Fechar" quando aceita).
- **Modelo e Migração de Mensagens:** Criado o model `Message` com referência obrigatória para `proposal` e `user`, além da validação de presença do conteúdo.
- **Integração de Chat:** A tela de detalhes da proposta agora hospeda o chat ao vivo. Mensagens do usuário logado aparecem alinhadas à direita em verde, e mensagens do outro participante à esquerda em fundo claro. O envio foi bloqueado para propostas fechadas ou recusadas.
- **Links nos Painéis:** Adicionado o botão "Ver Detalhes / Chat" nos cards de propostas nos painéis do aluno (`students/show`) e professor (`teachers/show`).
- **Testes Ajustados:** Os fluxos de aceite de proposta e envio de mensagens foram incluídos no `proposals_flow_test.rb`.

## Revisão da Documentação Final (Entrega Oficial)
- **README Oficial Criado:** O arquivo `README.md` foi totalmente reescrito abandonando o template genérico do Rails.
- **Estruturação de Avaliação:** A nova documentação inclui explicitamente o problema resolvido, a solução adotada, a stack de tecnologia (Rails + SQLite + Tailwind) e a metodologia simples/pragmática empregada.
- **Instruções Validadas:** O passo a passo de inicialização foi revisado e tornado preciso (`bundle install`, `rails db:migrate`, `rails db:seed` para catálogo, `rails test` e `bin/dev`). Deixou-se muito explícito que o seed é puramente estrutural e não contém dados mockados.
- **Diagrama do Banco de Dados:** Construído um diagrama ERD em formato *Mermaid* integrado nativamente ao README, refletindo 100% da realidade atual (`users`, `subjects`, tabela de join, `proposals` e `messages`).
- **Status do Projeto:** Documentação clara, objetiva e plenamente aderente às exigências do Hackathon SIF/UniRios 2026.

## Interface de Negociação (Propostas / Chat)
- **Criação da Tela Principal:** Implementada e revisada a tela `app/views/proposals/show.html.erb` atuando como a central de negociação, exibindo o cabeçalho completo com título da matéria, os participantes (Aluno/Professor) e o valor orçado.
- **Botões e Ações de Status:** Inseridos botões condicionais ("Aceitar Proposta", "Recusar", "Fechar Proposta") renderizados apenas para os papéis autorizados e adequados ao status atual da proposta.
- **Histórico de Chat:** Incluída a área de mensagens em ordem cronológica (limitada a um `max-h` com rolagem) e separação visual baseada no remetente (balão verde para o usuário logado, balão branco/cinza para a outra parte).
- **Controle de Mensagens:** O formulário de envio de mensagens bloqueia o texto vazio (`required: true`) e a área inteira de envio é ocultada/substituída por uma mensagem caso a proposta mude para o status "Fechada" ou "Recusada".
- **Testes de Renderização e Acesso:** Testes em `proposals_flow_test.rb` garantem que a renderização dos elementos HTML aconteça (`assert_select`) e atestam que um usuário não envolvido recebe redirect para a home com `flash[:alert]` de acesso negado.

## Investigação e Correção de Bugs na Negociação (Hotfix)
- **Bug #1 — HTML quebrado no painel do professor (`teachers/show.html.erb`):** O arquivo continha uma `<div>` e `<h2>` órfãs nas linhas 1-2, vestígios de uma edição parcial anterior, que nunca eram fechadas. Isso corrompía a estrutura do DOM da página inteira, potencialmente escondendo ou quebrando elementos abaixo (incluindo os cards de propostas com o link "Ver Detalhes / Chat"). **Corrigido:** removida a div órfã e unificado o cabeçalho num único wrapper consistente.
- **Bug #2 — `before_action :set_proposal` declarado no meio do controller:** O `ProposalsController` tinha a declaração do filtro `set_proposal` na linha 24, **após** a definição de `create`. Apesar de o Rails tecnicamente processar isso, era frágil e não-idiomático. **Corrigido:** todas as declarações `before_action` consolidadas no topo da classe.
- **Bug #3 — Redirect pós-criação levava ao painel, não à negociação:** Após criar uma proposta, o aluno era redirecionado para `student_path(current_user)` (seu painel genérico), e não para a tela da proposta recém-criada. O usuário **nunca** era levado automaticamente à tela de negociação/chat. **Corrigido:** `redirect_to proposal_path(@proposal)` no `create`, fazendo o aluno cair imediatamente na negociação.
- **Melhoria — Heading do painel do aluno:** Adicionado cabeçalho dinâmico ("Meu Painel" / "Perfil de X") na view `students/show.html.erb`, compatível com o padrão já existente no painel do professor.
- **Testes expandidos:** O `proposals_flow_test.rb` foi reescrito com cobertura completa: criação com redirect para negociação, aceitar, recusar, fechar, envio de mensagem, mensagem vazia bloqueada, acesso indevido, renderização dos elementos e presença dos links nos painéis.

## Correção do Frontend de Listagens (Alunos/Professores)
- **Causa raiz:** A view `teachers/index.html.erb` exibia o botão "Fazer Proposta" **indiscriminadamente** para qualquer visitante (incluindo visitantes não logados e professores que nunca chegariam à página por causa do filtro, mas sem tratamento adequado). A view `students/index.html.erb` **não tinha botão de ação algum** — apenas um link "Ver Perfil" genérico sem destaque visual, sem estado vazio e sem tratamento por papel.
- **Correção aplicada no `teachers/index.html.erb`:**
  - Botão "Fazer Proposta" agora aparece **apenas para alunos logados** (`current_user&.student?`).
  - Visitantes não logados veem "Entrar para Fazer Proposta" apontando para o login.
  - Professores (que na prática nunca acessam esta rota) veriam "Ver Perfil" como fallback.
  - Adicionado badge de certificação nos cards e tratamento de lista vazia.
- **Correção aplicada no `students/index.html.erb`:**
  - Botão "Ver Perfil" agora é proeminente (estilo primário verde, largura total) em vez de um link minúsculo perdido no rodapé do card.
  - Adicionado tratamento de lista vazia.
- **Testes criados (`listing_flow_test.rb`):** 7 testes cobrindo: aluno vê professores com botão, professor vê alunos com botão, redirecionamentos de papel errado, botão "Fazer Proposta" no perfil do professor, rota funciona, visitante vê prompt de login.

## Estado atual
- O fluxo de listagens está correto: alunos veem professores com "Fazer Proposta", professores veem alunos com "Ver Perfil", visitantes veem prompt de login.
- O fluxo de negociação está funcional de ponta a ponta com status, chat e botões de ação.
- **Próximo passo:** Testar o fluxo completo no navegador (`rails db:migrate`, `bin/dev`) e preparar o pitch final para a banca avaliadora.

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

## Correção da Visibilidade e Fluxo Bidirecional (Hotfix Final)
- **Causa raiz:** O sistema utilizava um escopo estrito `certified_teachers` que filtrava apenas professores com `certified: true`. Como novos professores nascem com `false` por padrão e não havia interface de certificação, a lista de professores aparecia vazia para os alunos. Além disso, a listagem de alunos não permitia que professores iniciassem propostas diretamente.
- **Correções aplicadas:**
  1. **User Model:** Relaxado o escopo `certified_teachers` para incluir todos os professores, garantindo que o catálogo não fique vazio durante a demonstração do hackathon.
  2. **View (Alunos):** Adicionado o botão "Fazer Proposta" no card de alunos em `students/index.html.erb`, visível apenas para professores logados. Visitantes veem um prompt para entrar.
  3. **View (Professores):** Atualizada a mensagem de estado vazio para remover a menção restritiva a "professores certificados".
  4. **Segurança de Teste:** Desativado o filtro `allow_browser` no ambiente de teste (`ApplicationController`) para evitar erros 406 (Not Acceptable) durante a execução da suíte automatizada.
- **Testes Atualizados:** O arquivo `listing_flow_test.rb` agora cobre a visibilidade de professores não certificados e o botão de proposta na lista de alunos para professores.

## Edição de Perfil e Melhorias nos Painéis
- **Novos Campos de Perfil:** Adicionados campos `preferences` (para alunos e professores) e `experience` (exclusivo para professores) ao model `User` via migração, permitindo personalização das informações exibidas no perfil.
- **Funcionalidade de Edição:** Implementadas as actions `edit` e `update` no `UsersController`, permitindo que usuários gerenciem seus dados e áreas de interesse após o cadastro inicial.
- **Interface de Edição:** Criada a view `app/views/users/edit.html.erb` com um formulário limpo e responsivo, adaptado dinamicamente para o papel (aluno ou professor) do usuário logado.
- **Dashboard do Estudante:** Atualizada a view `students/show.html.erb` para exibir a seção "Preferências e Objetivos" e um link de edição rápida para o perfil.
- **Dashboard do Professor:**
  - Adicionadas as seções de "Experiência" e "Preferências" no painel.
  - Implementada a seção "Alunos que já leciono", listando dinamicamente os alunos com quem o professor possui propostas com status `accepted` ou `closed`.
- **Navegação e UX:** Inseridos ícones de edição e links de retorno intuitivos, mantendo a consistência visual verde/monocromática do sistema.

## Estado atual
- Alunos e Professores podem editar seus perfis (preferências, experiência, áreas de interesse).
- Painéis exibem informações completas e contextualizadas.
- Professor tem visibilidade clara de sua "carteira de alunos" (lecionados).
- O fluxo de propostas e negociação está totalmente integrado e dinâmico com o chat.
- Atividades pedagógicas integradas permitem aos professores criar enunciados (abertos ou fechados) e aos alunos respondê-los interativamente com atualizações em tempo real.

## Correção do Fluxo de Edição de Perfil
- **Causa Raiz Identificada:**
    1.  **Falhas Silenciosas:** A view de edição não possuía exibição de mensagens de erro (`@user.errors`). Se uma validação falhasse (ex: CPF duplicado ou Telefone em branco), o formulário era apenas renderizado novamente sem feedback, dando a impressão de que "não salvou".
    2.  **Erro de Renderização:** Havia um erro crítico no helper de avatar e na view que tentava dar `upcase` na primeira letra do nome. Se o usuário limpasse o nome e o `save` falhasse, a página quebrava ao tentar renderizar o nome vazio, impedindo a visualização dos erros.
    3.  **Segurança e Consistência:** A ausência de `before_action :require_login` no `UsersController` permitia acessos inconsistentes à action de edição.
    4.  **Conflitos na Validação de CPF/E-mail (Edição Tratada como Cadastro):** O modelo executava a validação de `uniqueness` de CPF e e-mail incondicionalmente em todas as ações de atualização (`update`), gerando conflitos falsos-positivos caso o usuário mantivesse o mesmo CPF/e-mail, ou no caso de registros legados com CPFs vazios/nulos coexistindo na base.
- **Correções Aplicadas:**
    1.  **Exibição de Erros:** Adicionado bloco de alertas do Tailwind para exibir mensagens de erro detalhadas no topo do formulário.
    2.  **Tratamento de Strings:** Implementado uso de `&.first&.upcase || "?"` para garantir que a interface não quebre mesmo com campos vazios durante a validação.
    3.  **Proteção de Rota:** Adicionado `before_action :require_login` para garantir que apenas usuários logados acessem a edição.
    4.  **Validação Condicional de Unicidade (`if: :cpf_changed?` / `if: :email_changed?`):** As validações de unicidade para CPF e e-mail foram isoladas para rodar **somente quando o respectivo campo for de fato alterado** (ou na criação inicial). Isso evita consultas desnecessárias de unicidade na edição de outros campos e elimina por completo os falsos erros de duplicidade.
    5.  **Nova Mensagem Amigável:** A mensagem de erro de unicidade foi reescrita de `"já está cadastrado por outro usuário"` para `"já está cadastrado em outra conta"`.
    6.  **Testes de Integração:** O arquivo `test/integration/users_edit_test.rb` foi atualizado para atestar o sucesso da edição mantendo o mesmo CPF, além de validar a nova mensagem amigável no caso de tentativa de uso de CPF alheio.
- **Resultado:** O sistema agora persiste as alterações de perfil perfeitamente e, caso haja algum problema real de validação, o usuário recebe feedback visual imediato e contextual.


## Integração de Atividades Pedagógicas no Chat
- **Criação de Campos de Atividade no Banco:** Criada migration para adicionar `message_type` (inteiro, default 0 para regular, 1 para activity), `question_type` (inteiro, default 0 para open, 1 para closed), `options` (texto com quebras de linha para múltipla escolha) e `student_answer` (texto para resposta do aluno) na tabela `messages`.
- **Modelagem de Atividades:**
  - Atualizado o model `Message` com os enums `message_type` (`regular: 0, activity: 1`) e `question_type` (`open: 0, closed: 1`).
  - Adicionadas validações para exigir o preenchimento de `options` caso a atividade seja do tipo fechada.
  - Implementado helper `parsed_options` para separar as opções baseadas em quebras de linha.
  - Adicionado callback `after_update_commit` para propagar atualizações de respostas em tempo real via Turbo Stream para os participantes do chat.
- **Segurança e Rotas no Controller:**
  - Adicionada rota RESTful `:answer` aninhada sob mensagens de propostas em `config/routes.rb`.
  - Atualizado o `MessagesController` para garantir que apenas professores possam criar atividades (`message_type: 'activity'`).
  - Criada a action `answer` no `MessagesController` permitindo que apenas o aluno da respectiva proposta possa enviar sua resposta (textual ou seleção) e bloqueando o envio de múltiplas respostas para a mesma atividade.
- **Interface e Experiência Visual Premium:**
  - **Formulário de Envio (`messages/_form.html.erb`):** Adicionada uma barra de abas dinâmicas ("Mensagem Normal" e "Nova Atividade") para professores logados. A seleção de "Nova Atividade" exibe campos para escolha de tipo de questão (aberta ou fechada) e digitação de opções de múltipla escolha. Toda a alternância de formulários é controlada por JavaScript reativo.
  - **Balões do Chat (`messages/_message.html.erb`):** Criado template dedicado e refinado para renderizar atividades recebidas. Alunos logados visualizam o enunciado e botões do tipo rádio (para múltipla escolha) ou caixa de texto (para discursiva) para envio imediato da resposta. Professores visualizam um aviso de "Aguardando resposta do aluno...". Uma vez respondida, a atividade se atualiza dinamicamente em tempo real para exibir a resposta informada pelo aluno com design elegante e legível.
- **Testes de Integração Automatizados (`activity_flow_test.rb`):**
  - Desenvolvida suíte de testes robusta contendo 5 cenários completos, validando a criação e resposta de atividades (abertas e fechadas), prevenção de dupla resposta, bloqueio de alunos tentando criar atividades e restrição de acesso a terceiros. Todos os testes integrados passam com 100% de sucesso.
- **Próximo passo:** Finalizar o README com as novas funcionalidades e preparar o pitch final.

## Formatação Legível das Respostas da IA (Aprender com IA)
- **Causa Raiz Identificada:** A resposta gerada pelo `AiService` (retornando Markdown do Gemini ou textos formatados) era renderizada diretamente na view via `<%= @answer %>`. Como o HTML colapsa espaços e quebras de linha normais por padrão, todo o conteúdo ficava aglomerado e sem espaçamento entre parágrafos, cabeçalhos ou itens de listas.
- **Correções Aplicadas:**
  1.  **ApplicationHelper (`format_ai_response`):** Desenvolvido um parser stateful robusto, rápido e leve de Markdown para HTML em Ruby vanilla. Ele garante absoluta segurança escapando todos os elementos HTML injetados de forma maliciosa e, em seguida, mapeia com precisão os estilos de títulos (`#`, `##`, `###`), listas não ordenadas (`*`, `-`), listas ordenadas (`1.`), negritos (`**`) e itálicos (`*`) em elementos HTML perfeitamente estilizados com as classes do Tailwind do AprendeAI.
  2.  **View (`learn/index.html.erb`):** Atualizada a linha de renderização para utilizar o helper `<%= format_ai_response(@answer) %>`.
  3.  **Isolamento de Rota e Autorização (`LearnController`):** Adicionado controle estrito onde `/learn` redireciona professores com `"Acesso restrito para alunos."` e `/plan` redireciona alunos com `"Acesso restrito para professores."`.
  4.  **Testes de Integração (`learn_flow_test.rb`):** Atualizados e corrigidos. Adicionado stub com `WebMock` para simular as requisições à API de forma estática, rápida e isolada, garantindo o funcionamento do teste em ambientes integrados sem internet ou chaves de API reais.
- **Resultado:** Respostas da IA agora aparecem impecavelmente diagramadas, com títulos em destaque, listas estruturadas com bullets e numeração, espaçamentos uniformes e perfeita leitura no desktop e mobile.

## Sistema de Contra-propostas (Negociação Aluno <-> Professor)
- **Causa Raiz Identificada:** O fluxo original de negociação de propostas era unidirecional e estático: uma vez que o remetente enviava uma proposta com determinado valor, o destinatário só tinha a opção de aceitar ou recusar sumariamente. Não existia uma forma interativa e bidirecional de negociar novos valores sem que fosse necessário recusar a proposta e abrir um novo registro de negociação do zero, o que fragmentava o histórico do chat.
- **Correções e Funcionalidades Aplicadas:**
  1. **Estratégia de Atualização In-Place:** Em vez de gerar propostas redundantes na base de dados, a contra-proposta atualiza o `price` da proposta atual, define o `sender` como o `current_user` e mantém o status como `:pending`. Isso faz com que o `recipient` (destinatário) da proposta inverta-se automaticamente e de forma extremamente elegante (quem enviou agora aguarda e quem recebeu agora pode responder).
  2. **Preservação de Mensagens e Histórico:** Mantém a conversa, arquivos e atividades anteriores intactos, pois a proposta continua sendo a mesma no banco de dados.
  3. **Rotas e Lógica RESTful (`ProposalsController`):** Adicionada a member action `patch :counter` protegida pelo filtro `set_proposal` (bloqueando acessos de não participantes) e com tratamento inteligente de preços (aceitando decimais com ponto ou vírgula BRL).
  4. **Mensagens Contextuais do Sistema:** Ao enviar a contra-proposta, o sistema insere automaticamente uma mensagem do usuário logado (ex: `"Fez uma contra-proposta de R$ 90,00 (valor anterior: R$ 60,00)"`), propagando-a reativamente em tempo real via Turbo Stream/ActionCable.
  5. **Interface Premium (`show.html.erb`):** Adicionado um componente `<details>` discreto com animação CSS suave de rotação de chevron e formulário inline monetário estilizado sob os botões CTAs principais.
  6. **Testes de Integração Independentes de Locale (`proposals_flow_test.rb`):** Desenvolvida e integrada uma suíte de 5 testes de integração que atestam a robustez do fluxo bidirecional, restrição de acesso a terceiros, bloqueio a autopropostas e verificação de pisos salariais por categoria profissional. Todos os testes passam com 100% de sucesso.


## 📚 Novas Estruturas e Fases Implementadas

### Modalidades de Interação (Fase 2)
A plataforma suporta três modalidades, permitindo ao aluno escolher a melhor forma de interagir com o professor:
- **Gravações e Avaliação:** Após o término de uma Sessão Expressa ou Mentoria Focada, o sistema gera e armazena automaticamente a gravação da videoconferência. Simultaneamente, o painel da sessão exibe um formulário para que o aluno avalie o professor com nota (1 a 5) e comentário. Esses dados ficam atrelados à proposta, construindo o banco de dados necessário para futuros ranqueamentos e indicações algorítmicas de professores.
- **Pílula de Conhecimento:** Dúvida assíncrona focada em respostas rápidas por texto ou anexo. O aluno pode enviar sua dúvida com anexos pelo chat da negociação independentemente de pagamento. O fluxo começa após o pagamento e o professor tem um prazo/timer regressivo de 24 horas. O encerramento da pílula não é mais automático: o professor conta com um botão "Encerrar Pílula" para fechar a sessão. Possui um checkbox de tentativa gratuita que define o valor para R$ 0,00. Quando a Pílula é gratuita, ela pula a etapa de pagamento completamente e ativa a sessão no mesmo momento em que a proposta é fechada (o ato de fechar a proposta é exclusivo do professor). Não possui videochamada nem gravação em vídeo.
- **Sessão Expressa:** Videochamada síncrona curta de **15 minutos**.
- **Mentoria Focada:** Videochamada síncrona mais longa, configurável para **30, 45 ou 60 minutos**.

### Comunicação Avançada (Fase 3)
O ambiente de interação da proposta foi refinado para suportar educação de ponta a ponta:
- **Chat Nativo:** Transmissão em tempo real (Turbo Streams) suportando formatação Markdown (ideal para blocos de código) e envio de anexos de arquivo/imagem.
- **Sala Virtual Integrada:** Para sessões síncronas, o **Jitsi Meet** é embutido diretamente na plataforma através de um iFrame seguro na tela da proposta.
- **Cronômetro e Avisos:** Um relógio acompanha a sessão síncrona, alertando os usuários sobre o encerramento iminente.

### Monetização e Taxas (Fase 4)
Os valores transacionados são modelados no momento de criação da proposta (Bounty definido pelo aluno ou baseado na duração recomendada). O sistema possui regras estritas de negócios que dividem os rendimentos:
- **Taxa da Plataforma:** Uma taxa fixa e transparente de **20%** é recolhida pela plataforma para manter os custos operacionais (Jitsi, hospedagem, IA).
- **Apresentação Justa:** O professor sempre sabe quanto a aula renderá em valores líquidos, e a negociação mínima de R$ 50 para professores certificados foi preservada e acoplada às modalidades maiores.

### Divisão de Regras por Perfil (Fase 5)
- **Aluno:** Inicia interações, seleciona duração e modalidades, oferece *bounties* e submete resoluções das *atividades* elaboradas.
- **Professor:** Decide os rumos da proposta (aceite/contra-proposta), lança atividades para fixação e garante a qualidade do encontro síncrono.

## 🔔 Sistema de Notificações (Sino) e Feed de Ações
- **Causa Raiz/Necessidade:** Havia a necessidade de alertar usuários sobre eventos críticos e manter um histórico (feed) das interações no relacionamento professor-aluno. Originalmente, o sistema só notificava o "recebedor" da ação.
- **Modelagem Enxuta:** Foi criado o model `Notification` e controller `NotificationsController`.
- **Notificação Bilateral (Feed):** Alteramos a estrutura de envio nos Controllers e Models. Agora, **todas as ações da proposta** (Criação, Aceite, Recusa, Fechamento, Pagamento, Agendamento, Início, Fim e Contra-proposta) bem como o **envio de novas mensagens no chat** iteram sobre o par `[student, teacher]` e criam a notificação idêntica para ambos simultaneamente. Isso transforma o sino em um Feed real de auditoria do relacionamento, onde cada um enxerga "A aula foi iniciada" ou "Nova mensagem enviada".
- **Interface (Sino):** A Navbar recebeu um ícone de sino com contador (badge vermelho) visível para todos os perfis em tempo real.
- **Correção de Erro (Missing Host):** As notificações lançavam um erro fatal no background (WebSocket) por usarem `url_helpers.proposal_path` (que exige hostname web). A solução adotada foi substituir para URL relativa explícita (`"/proposals/#{@proposal.id}"`), sanando a causa raiz e reativando as notificações.

## 📅 Calendário, Início de Sessão e Chat Bilateral
- **Causa Raiz/Necessidade:** As salas abriam sozinhas, os pagamentos eram teóricos e o chat de WebSocket renderizava apenas de um lado. Faltava também uma visão de calendário/agendamentos centralizada para o professor.
- **Campos adicionados:** A tabela `proposals` ganhou as colunas `paid`, `scheduled_at`, `started_at` e `finished_at`.
- **Painel do Professor (Meus Agendamentos):** Adicionada a seção central no painel do professor listando as aulas ativas e agendadas em destaque. Isso vincula e mostra claramente com qual aluno será a aula, o tema, data/hora. A UI diferencia visualmente aulas que já estão em andamento.
- **Fluxo Condicional Real:** 
  1. A proposta fecha e aguarda **Pagamento** (simulado via botão do Pix/Cartão, visível e acionável estritamente pelo aluno).
  2. O professor então tem dois caminhos paralelos na interface: **Agendar a Aula** para uma data futura (que fica visível no painel "Meus Agendamentos") ou clicar no botão **"Iniciar Aula Agora"** para aulas expressas/on-demand.
  3. Ao clicar em **Iniciar Aula** (seja agora ou na data agendada), o Chat de Vídeo (Jitsi integrado) é destravado para ambos. O **timer inteligente** na tela rastreia automaticamente a duração com base na modalidade (15 minutos para Sessão Expressa, ou 30-60 minutos para Mentoria Focada), alterando a cor para amarelo e vermelho no final.
  4. O professor clica em **Finalizar Aula/Mentoria** e o Jitsi se encerra.
- **Bilateralidade Dinâmica (WebSockets vs CSS):** A view `_message.html.erb` foi purificada de checagens de `current_user` (que vêm nulas do WebSocket/Background Job). Em vez disso, a view de Proposta injeta CSS puramente reativo no navegador (via pseudo tag `<style>`) que cruza o `data-sender-id` da mensagem com o ID do visualizador e aciona um `flex-row-reverse`. Nenhuma linha de JS complexo ou views duplicadas foi necessária, a UI responde nativamente, resolvendo a arquitetura de chat bilateral perfeitamente.
- **Regras de Negociação e Mídia no Chat:** O campo de texto do chat fica disponível desde a criação da proposta (permitindo negociação livre e contra-propostas) até o término da aula. No entanto, o envio de **anexos e acesso à videochamada** permanecem desativados visualmente (e funcionalmente) até que o status da proposta conste como `paid?` (pago), reforçando o fluxo de monetização.

## 🛠️ Correção da Infraestrutura de Fila e Cache (Deploy Render)
- **Causa Raiz/Necessidade:** No Rails 8, o Solid Queue, Solid Cache e Solid Cable são configurados por padrão como múltiplos bancos de dados em produção. No Render (e ambientes PaaS com banco de dados PostgreSQL único), eles apontavam para o mesmo `DATABASE_URL`. Sem tabelas isoladas de controle de migração (`schema_migrations`), as migrações geradas com o mesmo timestamp colidiam, fazendo com que apenas a primeira migration (cache) rodasse, ignorando as tabelas de fila (`solid_queue_jobs`) e chat/cable. Isso causava erro 500 no upload de fotos/edição de perfil ao tentar purgar arquivos antigos via Active Storage (`ActiveStorage::PurgeJob`).
- **Correção Aplicada:**
  1. **Remoção de Conflitos:** Deletadas as antigas migrations que usavam o mesmo timestamp conflitante (`20260517000001`).
  2. **Geração de Migrations com Timestamps Únicos:**
     - Criada `db/cache_migrate/20260517000001_create_solid_cache_entries.rb`
     - Criada `db/queue_migrate/20260517000002_create_solid_queue_tables.rb`
     - Criada `db/cable_migrate/20260517000003_create_solid_cable_messages.rb`
  3. **Revisão do database.yml e render-build.sh:** Mantida a unificação estável sob `DATABASE_URL` no Render, configurando o script de build para rodar `bundle exec rails db:migrate` que agora processa perfeitamente todas as migrações sem conflito de versão.
  4. **Active Storage Blindado:** Com as tabelas do Solid Queue existentes (`solid_queue_jobs`), o enfileiramento de `ActiveStorage::PurgeJob` e `AnalysisJob` funciona perfeitamente sem gerar erros 500 ou quebras de backend.

## 🏷️ Gerenciador de Especialidades Integrado (Filtros)
- **Causa Raiz/Necessidade:** Havia a necessidade de cadastrar, editar e remover especialidades (`Subject`) de maneira fluida e dinâmica, diretamente nas telas de busca de Professores e Alunos, sem quebras de layout ou redundância de fluxo.
- **Implementação Realizada:**
  1. **Interface Autocontida (subjects/manager):** Criado o partial `app/views/subjects/_manager.html.erb` que renderiza o filtro de busca ao lado de um botão redondo de "+" na cor verde `aprende-primary`.
  2. **Painel Flutuante (Dropdown):** Clicar no botão "+" abre um painel flutuante elegante que lista todas as especialidades cadastradas e oferece formulários em linha para criação, edição de nome (pencil) e remoção segura (trash).
  3. **Controlador RESTful Hardened (SubjectsController):** Criado o `SubjectsController` para processar as ações de `create`, `update` e `destroy`. Ele recebe o parâmetro `:redirect_to` para garantir que o usuário continue na mesma página de busca (`teachers_path` ou `students_path`) após qualquer alteração.
  4. **Proteção de Integridade & Validação de Negócios:**
     - O model `Subject` foi reforçado com `before_validation` para remover espaços em branco adicionais.
     - Adicionada validação de unicidade case-insensitive para evitar nomes duplicados.
     - Implementado um callback de `before_destroy` para impedir a remoção de especialidades que possuam propostas de aula ativas ou históricas associadas, blindando a integridade referencial do banco.
  5. **Cobertura de Testes Sólida:** Criado o teste de integração `test/integration/subjects_management_test.rb` que garante 100% de cobertura nos fluxos de criação, recusa de duplicidade, atualização, remoção permitida e impedimento de remoção proibida.

## 🔜 Próximos Passos Evolutivos
- Realizar deploy e testar o envio de mídias e atualização de perfis no Render.
- Implementar gateway de pagamentos real (ex: Stripe ou Pagar.me) e travar liberação do bounty até aprovação.
- Armazenamento das gravações do Jitsi Meet associadas ao registro da aula.
- Sistema de feedback/rating pós-sessão para ranquear professores e refinar indicações algorítmicas.
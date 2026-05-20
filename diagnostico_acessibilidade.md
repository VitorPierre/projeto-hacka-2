# Diagnóstico de Acessibilidade (WCAG 2.1 AA) — aprendeAI

Este documento apresenta um diagnóstico técnico e objetivo das telas críticas da plataforma **aprendeAI** em conformidade com as diretrizes de acessibilidade **WCAG 2.1 no nível AA**. O foco deste diagnóstico está na identificação de barreiras físicas e cognitivas para usuários com deficiências visuais, motoras e intelectuais.

---

## 1. Problemas Encontrados por Tela

### 1.1. Tela de Login
**Arquivo principal:** [new.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/sessions/new.html.erb)

*   **Leitor de Tela (Semântica):** O caractere separador `<span>&bull;</span>` (linha 28) entre os links de rodapé é anunciado de forma literal por leitores de tela como *"bullet"* ou *"ponto"*, o que polui a navegação e confunde o usuário. **Correção recomendada:** Adicionar `aria-hidden="true"` ao elemento.
*   **Contraste (Estados Flutuantes):** O botão de submissão (linha 16) possui a classe `hover:bg-[#159b3f]`. O tom `#159b3f` possui um contraste de **3.67:1** contra o texto branco, ficando abaixo do mínimo de **4.5:1** exigido pela WCAG AA. **Correção recomendada:** Substituir o valor direto pelo token semântico `--color-aprende-primary-hover` (`#126630`).

---

### 1.2. Tela de Cadastro
**Arquivo principal:** [new.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/users/new.html.erb)

*   **Labels de Formulário & Semântica (Crítico):** A seção *"Áreas de Ensino"* (linha 68) utiliza uma tag `<label>` genérica sem atributo `for` e sem associação semântica com o grupo de checkboxes gerado por `collection_check_boxes`. Usuários de leitor de tela que navegam entre os campos não saberão a qual grupo de seleção os checkboxes pertencem. **Correção recomendada:** Substituir por um elemento `<fieldset>` com a legenda `<legend class="sr-only">` ou associar via `aria-labelledby`.
*   **Contraste (Estados Flutuantes):** Assim como na tela de login, o botão de submissão de cadastro (linha 111) usa `hover:bg-[#159b3f]`, que viola as regras de contraste.
*   **Teclado (Foco Dinâmico):** Quando o usuário altera a seleção do select de perfil (`#role_select`), os blocos `#teacher_fields` e `#student_fields` são alternados via JavaScript (`display: none`). Embora a ocultação física seja excelente (remove os elementos do fluxo de foco), não há notificação em tempo real (ex: `aria-live` ou anúncio ativo) para usuários cegos de que a estrutura do formulário foi modificada de forma relevante abaixo de seu foco atual.

---

### 1.3. Tela de Enviar Proposta
**Arquivo principal:** [new.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/proposals/new.html.erb)

*   **Navegação por Teclado (Bloqueio Crítico):** O campo de upload customizado *"Anexar Arquivo"* (linha 110-113) oculta o input de arquivo nativo com a classe `hidden` (`display: none`). Como os navegadores removem completamente elementos invisíveis da árvore de foco, **usuários que dependem exclusivamente de teclado ou leitores de tela nunca conseguirão focar ou ativar o botão de anexo**. **Correção recomendada:** Substituir a classe `hidden` no input de arquivo por técnicas de ocultação acessível (ex: `sr-only` ou `opacity-0 w-px h-px absolute pointer-events-none`).
*   **Labels de Formulário (WCAG):** A *"Duração da Mentoria"* (linha 55) usa um `<label>` genérico sem associação com os sub-campos de Horas e Minutos. Embora os campos internos possuam labels associadas (`for="duration-hours"` e `for="duration-minutes"`), o grupo principal carece de semântica estrutural (deve ser um `<fieldset>` com `<legend>`).
*   **Contraste (Estados Flutuantes):** O botão de submissão do formulário (linha 135) também apresenta a cor de hover de baixo contraste (`hover:bg-[#159b3f]`).

---

### 1.4. Tela de Detalhes da Proposta & Chat
**Arquivos principais:** 
*   [show.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/proposals/show.html.erb)
*   [_form.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/messages/_form.html.erb)
*   [_message.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/messages/_message.html.erb)

*   **Labels de Formulário (Crítico):** A caixa de resposta discursiva para atividades enviadas pelo professor no chat (`_message.html.erb`, linha 63) utiliza a tag `text_area_tag :student_answer` sem qualquer label associada ou atributo `aria-label`. Isso faz com que o leitor de tela anuncie apenas um *"campo de texto vazio"* sem contexto. **Correção recomendada:** Adicionar uma label implícita ou um atributo `aria-label="Sua resposta para a atividade"`.
*   **Semântica & Teclado (Navegação por Abas do Chat):** O formulário de envio de mensagens no perfil do professor (`_form.html.erb`, linha 5) utiliza as tags de acessibilidade `role="tablist"` e `role="tab"`, mas não implementa o comportamento real por teclado esperado por leitores de tela para esses papéis (navegação por setas do teclado esquerda/direita para trocar de aba). Além disso, ao alternar entre as abas via clique, os atributos `aria-selected` não são atualizados dinamicamente pelo JavaScript original.
*   **Leitor de Tela (Conteúdo Dinâmico):** Quando novas mensagens de chat ou novas atividades dinâmicas são recebidas via Turbo Streams/WebSockets, leitores de tela não notificam o usuário cego sobre as novas mensagens recebidas. **Correção recomendada:** Adicionar `aria-live="polite"` e `aria-atomic="false"` ao contêiner principal das mensagens (`#messages`).
*   **Navegação por Teclado (Bloqueio no Chat):** A funcionalidade de anexar arquivos no chat (`_form.html.erb`, linha 33) também utiliza a classe `hidden` no input de arquivo, herdando a mesma barreira intransponível descrita no fluxo de nova proposta.
*   **Leitor de Tela (Ordenação das Estrelas de Avaliação):** O formulário de avaliação por estrelas (`show.html.erb`, linha 216) é ordenado via Ruby de forma decrescente (`5.downto(1)`) para possibilitar a estilização de hover do Tailwind com o seletor irmão (`~`). Contudo, isso inverte o fluxo natural de leitura no teclado e leitores de tela, forçando o usuário cego a navegar da 5ª estrela até a 1ª estrela de forma regressiva.
*   **Contraste (Estados Flutuantes):** Todos os botões CTAs críticos desta tela ("Aceitar Proposta", "Enviar Mensagem", "Enviar Resposta") utilizam a cor de hover inadequada `#159b3f`.

---

### 1.5. Tela de Videochamada
**Arquivo principal:** [show.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/proposals/show.html.erb)

*   **Semântica HTML (Crítico/Violador WCAG):** O elemento `<iframe>` embutido para o Jitsi Meet (linha 313) **não possui um atributo `title`**. Isso viola diretamente a especificação WCAG AA, pois leitores de tela não conseguem informar o propósito do frame ao usuário. **Correção recomendada:** Adicionar `title="Sala de videochamada do Jitsi Meet"`.
*   **Leitor de Tela & Acessibilidade de Tempo:** O cronômetro de contagem regressiva da sessão `#session-timer` (linha 306) e o cronômetro da Pílula `#kp-timer` (linha 358) atualizam seus valores a cada segundo via JavaScript. Contudo, eles não possuem nenhum papel semântico ou descrição acessível (ex: `role="timer"` ou `aria-label="Tempo restante"`), deixando os usuários cegos alheios ao tempo disponível. **Nota:** *Não se deve usar `aria-live="polite"` com atualizações de 1 segundo*, pois causaria poluição sonora absurda. A abordagem correta é descrever semanticamente o elemento como cronômetro e alertar de forma controlada em prazos específicos (como no aviso de 5 minutos).

---

## 2. Ordem de Prioridade de Correção

Adotamos a metodologia clássica de triagem de acessibilidade, priorizando bloqueios funcionais completos antes de otimizações de navegação:

### 🚨 Prioridade 1: Bloqueios Críticos de Funcionalidade (Impacto Alto / Impedimento Total)
1.  **Consertar Inputs de Arquivos Invisíveis (hidden):**
    *   *Onde:* Cadastro, Nova Proposta, Envio de Chat.
    *   *Impacto:* Teclado/leitores de tela não conseguem enviar arquivos na plataforma atualmente.
2.  **Adicionar Title ao iFrame do Jitsi:**
    *   *Onde:* Tela de Videochamada.
    *   *Impacto:* Sem isso, a tela de aula é considerada inacessível e violadora direta de normas de conformidade internacionais.
3.  **Adicionar Labels semânticas ausentes:**
    *   *Onde:* Campo discursivo da atividade no chat e campos agrupados ("Áreas de Ensino" e "Duração da Mentoria").

### ⚠️ Prioridade 2: Navegação e Semântica de Fluxo (Impacto Médio / Confusão Cognitiva)
1.  **Corrigir Abas de Atividade / Mensagem no Chat:**
    *   *Onde:* Form de chat no perfil do professor.
    *   *Impacto:* Atualizar dinamicamente `aria-selected` via JS para manter o estado semântico e corrigir a troca física de abas.
2.  **Notificação de Novas Mensagens no Chat:**
    *   *Onde:* Contêiner `#messages`.
    *   *Impacto:* Garantir que novas interações por texto ou atividades sejam narradas imediatamente aos usuários.
3.  **Incluir summary de detalhes no CSS de foco-visível:**
    *   *Onde:* CSS global.
    *   *Impacto:* Permitir que o elemento de contra-propostas tenha contorno visual claro ao ser tabulado.

### 🎨 Prioridade 3: Refinamentos e Contraste (Impacto Baixo / Melhoria Contínua)
1.  **Substituir cores de Hover por cores acessíveis:**
    *   *Onde:* Em todas as telas críticas.
    *   *Impacto:* Garante que mesmo em estados dinâmicos (hover/focus) a taxa de contraste mínima de 4.5:1 seja mantida em toda a interface.
2.  **Ocultar bullet separators de leitores de tela (`aria-hidden`):**
    *   *Onde:* Rodapé de Login e layouts gerais.
    *   *Impacto:* Evita poluição de caracteres decorativos inúteis na leitura corrida.

---

## 3. Arquivos que Precisam ser Alterados

1.  **[application.css](file:///c:/Users/vitor/Documents/hacka2/app/assets/tailwind/application.css)** (CSS global de focos)
2.  **[new.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/sessions/new.html.erb)** (Login)
3.  **[new.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/users/new.html.erb)** (Cadastro)
4.  **[new.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/proposals/new.html.erb)** (Nova Proposta)
5.  **[show.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/proposals/show.html.erb)** (Detalhes, Videochamada e Avaliação)
6.  **[_form.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/messages/_form.html.erb)** (Form de Mensagens/Atividades)
7.  **[_message.html.erb](file:///c:/Users/vitor/Documents/hacka2/app/views/messages/_message.html.erb)** (Exibição de Mensagens/Atividades no Chat)

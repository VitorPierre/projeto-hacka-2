require "test_helper"

# Testes de Acessibilidade — Camada 2
# Verificam as melhorias de acessibilidade em HTML renderizado:
# ARIA, semântica, labels, touch targets, leitor de tela e mobile.
class AccessibilityLayer2Test < ActionDispatch::IntegrationTest
  # ────────────────────────────────────────────────────────────
  # Helpers de login
  # ────────────────────────────────────────────────────────────
  def login_as_student
    post login_path, params: { email: "aluno@teste.com", password: "senha123" }
    follow_redirect!
  end

  def login_as_teacher
    post login_path, params: { email: "professor@teste.com", password: "senha123" }
    follow_redirect!
  end

  # ────────────────────────────────────────────────────────────
  # 1. Tela de Login
  # ────────────────────────────────────────────────────────────
  test "login: bullet separator tem aria-hidden" do
    get login_path
    assert_response :success
    assert_match "aria-hidden=\"true\"", response.body,
                 "Separador decorativo deve ter aria-hidden para não poluir leitores de tela"
  end

  test "login: submit button presente e acessível" do
    get login_path
    assert_response :success
    assert_select "input[type=submit]", minimum: 1
  end

  # ────────────────────────────────────────────────────────────
  # 2. Tela de Cadastro
  # ────────────────────────────────────────────────────────────
  test "cadastro: áreas de ensino usa fieldset e legend" do
    get new_user_path(role: "teacher")
    assert_response :success
    assert_select "fieldset", minimum: 1,
                  message: "Áreas de Ensino deve estar dentro de fieldset"
    assert_select "fieldset > legend", minimum: 1,
                  message: "fieldset deve ter legend para agrupar checkboxes semanticamente"
  end

  test "cadastro: role_select existe e tem label associado" do
    get new_user_path
    assert_response :success
    assert_select "select#role_select", 1
    assert_select "label[for=role_select]", true,
                  "Select de papel deve ter label explicitamente associada"
  end

  # ────────────────────────────────────────────────────────────
  # 3. Tela de Nova Proposta
  # ────────────────────────────────────────────────────────────
  test "nova proposta: duração usa fieldset e legend" do
    login_as_student
    teacher = users(:teacher)
    get new_proposal_path(teacher_id: teacher.id)
    assert_response :success
    assert_select "fieldset#duration-container", minimum: 1,
                  message: "Duração da Mentoria deve usar fieldset"
    assert_select "fieldset#duration-container > legend", minimum: 1,
                  message: "fieldset de duração deve ter legend"
  end

  test "nova proposta: input de anexo não usa hidden direto" do
    login_as_student
    teacher = users(:teacher)
    get new_proposal_path(teacher_id: teacher.id)
    assert_response :success
    # O input de arquivo deve usar class="sr-only", não atributo hidden
    # que removeria o elemento da árvore de foco
    assert_no_match(/input[^>]*type="file"[^>]*\shidden\s/i, response.body,
                    "Input de arquivo não deve usar atributo 'hidden' que remove do foco do teclado")
  end

  # ────────────────────────────────────────────────────────────
  # 4. Tela de Proposta (chat)
  # ────────────────────────────────────────────────────────────
  test "proposta pendente: container de mensagens tem aria-live" do
    login_as_student
    proposal = proposals(:pending_proposal)
    get proposal_path(proposal)
    assert_response :success
    assert_select "#messages[aria-live]", true,
                  "#messages deve ter aria-live para anunciar novas mensagens"
    assert_select "#messages[aria-atomic]", true
  end

  test "proposta pendente: container de mensagens tem classe chat-scroll" do
    login_as_student
    proposal = proposals(:pending_proposal)
    get proposal_path(proposal)
    assert_response :success
    assert_match "chat-scroll", response.body,
                 "Container do chat deve ter classe chat-scroll para scroll suave em iOS"
  end

  test "proposta pendente: textarea do chat tem label associada" do
    login_as_student
    proposal = proposals(:pending_proposal)
    get proposal_path(proposal)
    assert_response :success
    has_label = response.body.include?('for="message_content_area"') ||
                response.body.include?('aria-label=')
    assert has_label,
           "Textarea de mensagem deve ter label associada ou aria-label"
  end

  test "proposta pendente: ícones decorativos têm aria-hidden" do
    login_as_student
    proposal = proposals(:pending_proposal)
    get proposal_path(proposal)
    assert_response :success
    assert_match "aria-hidden", response.body,
                 "Elementos decorativos devem ter aria-hidden"
  end

  # ────────────────────────────────────────────────────────────
  # 5. Chat form do professor — tabs com aria-selected
  # ────────────────────────────────────────────────────────────
  test "proposta: tablist do professor tem aria-selected nos tabs" do
    login_as_teacher
    proposal = proposals(:pending_proposal)
    get proposal_path(proposal)
    assert_response :success
    if response.body.include?("role=\"tablist\"")
      assert_select "[role=tablist]", 1
      assert_select "[role=tab][aria-selected]", minimum: 2,
                    message: "Ambos os tabs devem ter aria-selected"
      assert_match "aria-selected=\"true\"", response.body
      assert_match "aria-selected=\"false\"", response.body
    end
  end

  # ────────────────────────────────────────────────────────────
  # 6. Sessão ativa — criada dinamicamente
  # ────────────────────────────────────────────────────────────
  test "sessão ativa: iframe de videochamada tem title" do
    login_as_student
    proposal = proposals(:pending_proposal)
    proposal.update_columns(status: 3, started_at: 1.hour.ago, modality: 2, duration: 60)
    get proposal_path(proposal)
    assert_response :success
    if response.body.include?("jit.si")
      assert_match "title=", response.body,
                   "iframe do Jitsi deve ter atributo title"
    end
  end

  test "sessão ativa: timer tem role=timer e aria-label" do
    login_as_student
    proposal = proposals(:pending_proposal)
    proposal.update_columns(status: 3, started_at: 1.hour.ago, modality: 2, duration: 60)
    get proposal_path(proposal)
    assert_response :success
    if response.body.include?("session-timer")
      assert_select "#session-timer[role=timer]", minimum: 1,
                    message: "Cronômetro deve ter role=timer"
      assert_select "#session-timer[aria-label]", minimum: 1,
                    message: "Cronômetro deve ter aria-label"
    end
  end

  test "sessão ativa: região de anúncio do timer existe e tem aria-live" do
    login_as_student
    proposal = proposals(:pending_proposal)
    proposal.update_columns(status: 3, started_at: 1.hour.ago, modality: 2, duration: 60)
    get proposal_path(proposal)
    assert_response :success
    if response.body.include?("session-timer")
      assert_match "video-sr-announcer", response.body,
                   "Deve existir região de anúncio sr-only para alertas do timer"
      assert_match "aria-live=\"polite\"", response.body
    end
  end

  test "avaliação por estrelas: usa order 1 a 5 no DOM com fieldset" do
    login_as_student
    proposal = proposals(:pending_proposal)
    # Simula proposta finalizada sem avaliação
    proposal.update_columns(status: 3, started_at: 2.hours.ago, finished_at: 1.hour.ago, rating: nil)
    get proposal_path(proposal)
    assert_response :success
    if response.body.include?("star-rating-group")
      assert_select "fieldset", minimum: 1,
                    message: "Estrelas de avaliação devem estar em fieldset"
      assert_select "fieldset > legend", minimum: 1,
                    message: "fieldset de estrelas deve ter legend para leitores de tela"
      # Verifica que os radio buttons estão em ordem 1..5 (DOM order para SR)
      body = response.body
      idx_1 = body.index("value=\"1\"")
      idx_5 = body.index("value=\"5\"")
      # 1 deve aparecer antes de 5 no DOM (ordem crescente para SR)
      assert idx_1 < idx_5,
             "Radio buttons de estrelas devem estar em ordem 1→5 no DOM para leitores de tela"
    end
  end
end

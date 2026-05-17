require "test_helper"
require "webmock/minitest"

class AiServiceTest < ActiveSupport::TestCase
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    ENV["GEMINI_API_KEY"] = "fake_key"
  end

  test "should return AI response for student when API succeeds" do
    stub_request(:post, /generativelanguage.googleapis.com/)
      .to_return(status: 200, body: {
        candidates: [
          { content: { parts: [ { text: "Resposta da IA para o aluno" } ] } }
        ]
      }.to_json)

    answer = AiService.call(@student, "O que é fotossíntese?")
    assert_equal "Resposta da IA para o aluno", answer
  end

  test "should return AI response for teacher when API succeeds" do
    stub_request(:post, /generativelanguage.googleapis.com/)
      .to_return(status: 200, body: {
        candidates: [
          { content: { parts: [ { text: "Plano de aula gerado" } ] } }
        ]
      }.to_json)

    answer = AiService.call(@teacher, "Plano de aula sobre frações")
    assert_equal "Plano de aula gerado", answer
  end

  test "should return fallback when API fails" do
    stub_request(:post, /generativelanguage.googleapis.com/)
      .to_return(status: 500)

    answer = AiService.call(@student, "O que é fotossíntese?")
    assert_match(/Sobre 'O que é fotossíntese\?'/, answer) # Check if it uses fallback
  end

  test "should return education restricted message for off-topic questions" do
    answer = AiService.call(@student, "Comprar criptomoedas")
    assert_match(/foco é exclusivamente em educação/, answer)
  end
end

require "test_helper"
require "webmock/minitest"

class LearnFlowTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    ENV["GEMINI_API_KEY"] = "fake_key"
  end

  test "student can access learn page" do
    post login_path, params: { email: @student.email, password: "senha123" }
    get learn_path
    assert_response :success
    assert_select "h2", text: /Aprender com AI/
  end

  test "teacher cannot access learn page" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    get learn_path
    assert_redirected_to root_path
    assert_equal "Acesso restrito para alunos.", flash[:alert]
  end

  test "student can ask a question" do
    stub_request(:post, /generativelanguage.googleapis.com/)
      .to_return(status: 200, body: {
        candidates: [
          { content: { parts: [ { text: "Matemática é a ciência que estuda quantidades, espaço e estruturas." } ] } }
        ]
      }.to_json)

    post login_path, params: { email: @student.email, password: "senha123" }
    get learn_path, params: { question: "O que é matemática?" }
    assert_response :success
    assert_select "div", text: /ciência que estuda quantidades/
  end
end

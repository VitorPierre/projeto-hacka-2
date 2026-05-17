require "test_helper"

class SubjectsManagementTest < ActionDispatch::IntegrationTest
  setup do
    @subject = subjects(:math)
    @orphan_subject = subjects(:programming)
  end

  test "should create a new specialty and redirect back" do
    assert_difference("Subject.count", 1) do
      post subjects_path, params: {
        subject: { name: "  Nova Especialidade de Teste  " },
        redirect_to: teachers_path
      }
    end

    created_subject = Subject.last
    assert_equal "Nova Especialidade de Teste", created_subject.name
    assert_redirected_to teachers_path
    follow_redirect!
    assert_match "Especialidade &#39;Nova Especialidade de Teste&#39; adicionada com sucesso!", response.body
  end

  test "should not duplicate specialties case-insensitively" do
    assert_no_difference("Subject.count") do
      post subjects_path, params: {
        subject: { name: @subject.name.downcase },
        redirect_to: teachers_path
      }
    end

    assert_redirected_to teachers_path
    follow_redirect!
    assert_match "Erro ao adicionar especialidade: Name has already been taken", response.body
  end

  test "should update specialty name" do
    patch subject_path(@subject), params: {
      subject: { name: "Novo Nome de Especialidade" },
      redirect_to: teachers_path
    }

    assert_redirected_to teachers_path
    follow_redirect!
    assert_match "Especialidade atualizada para &#39;Novo Nome de Especialidade&#39;!", response.body
    @subject.reload
    assert_equal "Novo Nome de Especialidade", @subject.name
  end

  test "should remove a specialty with no proposals" do
    assert_difference("Subject.count", -1) do
      delete subject_path(@orphan_subject), params: {
        redirect_to: teachers_path
      }
    end

    assert_redirected_to teachers_path
    follow_redirect!
    assert_match "Especialidade &#39;#{@orphan_subject.name}&#39; removida com sucesso!", response.body
  end

  test "should not remove a specialty with associated proposals" do
    assert_no_difference("Subject.count") do
      delete subject_path(@subject), params: {
        redirect_to: teachers_path
      }
    end

    assert_redirected_to teachers_path
    follow_redirect!
    assert_match "Esta especialidade possui propostas de aula vinculadas e não pode ser removida.", response.body
  end
end

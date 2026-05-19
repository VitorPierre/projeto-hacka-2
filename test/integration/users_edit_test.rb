require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
  end

  test "student can edit profile" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    patch user_path(@student), params: { 
      user: { 
        name: "Novo Nome Aluno",
        preferences: "Novas preferências"
      } 
    }
    
    assert_redirected_to student_path(@student)
    @student.reload
    assert_equal "Novo Nome Aluno", @student.name
    assert_equal "Novas preferências", @student.preferences
  end

  test "student can edit profile keeping the same CPF" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    patch user_path(@student), params: { 
      user: { 
        name: "Novo Nome Aluno",
        cpf: "111.222.333-44",
        phone: "(11) 99999-9999",
        preferences: "Novas preferências"
      } 
    }
    
    assert_redirected_to student_path(@student)
    @student.reload
    assert_equal "Novo Nome Aluno", @student.name
  end

  test "teacher can edit profile" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    patch user_path(@teacher), params: { 
      user: { 
        name: "Novo Nome Professor",
        experience: "Nova experiência",
        education_level: "higher"
      } 
    }
    
    assert_redirected_to teacher_path(@teacher)
    @teacher.reload
    assert_equal "Novo Nome Professor", @teacher.name
    assert_equal "Nova experiência", @teacher.experience
    assert_equal "higher", @teacher.education_level
  end

  test "teacher can edit profile keeping the same CPF" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    patch user_path(@teacher), params: { 
      user: { 
        name: "Novo Nome Professor",
        cpf: "555.666.777-88",
        phone: "(11) 88888-8888",
        experience: "Nova experiência",
        education_level: "higher",
        certificate_url: "http://certificado.com"
      } 
    }
    
    assert_redirected_to teacher_path(@teacher)
    @teacher.reload
    assert_equal "Novo Nome Professor", @teacher.name
  end

  test "should show errors on invalid update" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    patch user_path(@student), params: { 
      user: { 
        name: "",
        email: "invalido"
      } 
    }
    
    assert_response :unprocessable_entity
  end

  test "should fail if trying to update to another user's CPF" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    patch user_path(@student), params: { 
      user: { 
        cpf: @teacher.cpf
      } 
    }
    
    assert_response :unprocessable_entity
    assert_select "li", text: "Cpf já está cadastrado em outra conta"
  end

  test "should fail if trying to update another user's profile" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    get edit_user_path(@teacher)
    assert_redirected_to root_path
    assert_equal "Acesso não autorizado.", flash[:alert]
    
    patch user_path(@teacher), params: {
      user: {
        name: "Hackeado"
      }
    }
    assert_redirected_to root_path
    assert_equal "Acesso não autorizado.", flash[:alert]
    @teacher.reload
    assert_not_equal "Hackeado", @teacher.name
  end

  test "teacher can add and edit presentation video url" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    # 1. First, make sure the video is not present on show page
    get teacher_path(@teacher)
    assert_response :success
    assert_select "iframe[src*='youtube.com']", 0
    assert_select "h3", text: "Vídeo de Apresentação", count: 0

    # 2. Add the video URL
    patch user_path(@teacher), params: {
      user: {
        presentation_video_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      }
    }
    
    assert_redirected_to teacher_path(@teacher)
    @teacher.reload
    assert_equal "https://www.youtube.com/watch?v=dQw4w9WgXcQ", @teacher.presentation_video_url
    
    # 3. Follow redirect and check that iframe is rendered
    follow_redirect!
    assert_response :success
    assert_select "iframe[src='https://www.youtube.com/embed/dQw4w9WgXcQ']"
    assert_select "h3", text: "Vídeo de Apresentação"
  end
end

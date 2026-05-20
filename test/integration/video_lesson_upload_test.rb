require "test_helper"

class VideoLessonUploadTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
    @proposal = proposals(:pending_proposal)
    # Put the proposal in closed/finished state to match standard view logic
    @proposal.update!(status: :accepted)
    @proposal.update!(status: :closed, paid: true, started_at: 1.hour.ago, finished_at: Time.current)
  end

  test "teacher successfully uploads a valid video lesson" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    assert_redirected_to teacher_path(@teacher) # dashboard redirects to appropriate path
    
    # Upload videoaula
    patch upload_videoaula_proposal_path(@proposal), params: { 
      videoaula: fixture_file_upload('dummy_video.mp4', 'video/mp4') 
    }
    
    assert_redirected_to proposal_path(@proposal)
    follow_redirect!
    
    assert_equal "Videoaula enviada com sucesso!", flash[:notice]
    @proposal.reload
    assert @proposal.videoaula.attached?
    assert_equal "dummy_video.mp4", @proposal.videoaula.filename.to_s
    
    # View proposal page and check for HTML5 video player
    get proposal_path(@proposal)
    assert_response :success
    assert_select "video[aria-label='Videoaula gravada']" do
      assert_select "source[type='video/mp4']"
    end
    # Ensure upload form is NOT shown since videoaula is already attached
    assert_select "form[action=?]", upload_videoaula_proposal_path(@proposal), false
  end

  test "teacher attempts to upload invalid file format" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    patch upload_videoaula_proposal_path(@proposal), params: { 
      videoaula: fixture_file_upload('invalid_file.txt', 'text/plain') 
    }
    
    assert_redirected_to proposal_path(@proposal)
    follow_redirect!
    
    assert_match "Não foi possível enviar a videoaula: Videoaula deve ser um arquivo de vídeo válido", flash[:alert]
    @proposal.reload
    assert_not @proposal.videoaula.attached?
  end

  test "student attempts to upload a video lesson and is unauthorized" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    patch upload_videoaula_proposal_path(@proposal), params: { 
      videoaula: fixture_file_upload('dummy_video.mp4', 'video/mp4') 
    }
    
    assert_redirected_to proposal_path(@proposal)
    follow_redirect!
    
    assert_equal "Apenas o professor desta proposta pode enviar a videoaula.", flash[:alert]
    @proposal.reload
    assert_not @proposal.videoaula.attached?
  end

  test "uninvolved user attempts to upload a video lesson" do
    uninvolved_user = User.create!(
      name: "Outro", 
      email: "outro@usuario.com", 
      password: "password123", 
      role: "student", 
      phone: "11933333333", 
      cpf: "99988877766"
    )
    
    post login_path, params: { email: uninvolved_user.email, password: "password123" }
    
    patch upload_videoaula_proposal_path(@proposal), params: { 
      videoaula: fixture_file_upload('dummy_video.mp4', 'video/mp4') 
    }
    
    assert_redirected_to root_path
    follow_redirect!
    assert_equal "Proposta não encontrada ou acesso negado.", flash[:alert]
    
    @proposal.reload
    assert_not @proposal.videoaula.attached?
  end

  test "student views proposal page when videoaula is not uploaded yet" do
    post login_path, params: { email: @student.email, password: "senha123" }
    
    get proposal_path(@proposal)
    assert_response :success
    
    # Shows alert banner for students
    assert_select "h3", "Aguardando Videoaula"
    assert_select "p", "A videoaula está sendo processada ou será disponibilizada em breve pelo professor."
    
    # Ensure student cannot see upload form
    assert_select "form[action=?]", upload_videoaula_proposal_path(@proposal), false
  end

  test "teacher views proposal page when videoaula is not uploaded yet" do
    post login_path, params: { email: @teacher.email, password: "senha123" }
    
    get proposal_path(@proposal)
    assert_response :success
    
    # Shows direct upload form for teachers
    assert_select "h3", "Disponibilizar Videoaula"
    assert_select "form[action=?]", upload_videoaula_proposal_path(@proposal) do
      assert_select "input[type='file'][data-direct-upload-url]"
      assert_select "input[type='submit']"
    end
  end

  test "videoaula file size validation works correctly" do
    # We test size validation at the model level via a unit test to be fast and safe
    proposal = proposals(:pending_proposal)
    proposal.videoaula.attach(io: StringIO.new("Fake video content"), filename: "dummy.mp4", content_type: "video/mp4")
    
    assert proposal.valid?
    
    # Mocking byte_size through a direct singleton method on the attachment proxy
    attached_one = proposal.videoaula
    def attached_one.byte_size
      101.megabytes
    end
    
    assert_not proposal.valid?
    assert_includes proposal.errors[:videoaula], "deve ter tamanho inferior a 100 MB"
  end
end

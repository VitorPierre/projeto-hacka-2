require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "invalid without name" do
    user = User.new(email: "test@test.com", password: "password")
    assert_not user.valid?
  end

  test "invalid without email" do
    user = User.new(name: "Test", password: "password")
    assert_not user.valid?
  end

  test "teacher requires certificate_url" do
    teacher = User.new(name: "Prof", email: "p@t.com", password: "pw", role: :teacher, phone: "11999999999", cpf: "12345678901")
    assert_not teacher.valid?
    teacher.certificate_url = "http://link.com"
    assert teacher.valid?
  end

  test "certified_teachers scope returns all teachers for hackathon flow" do
    teachers = User.certified_teachers
    assert_includes teachers, users(:teacher)
    assert_includes teachers, users(:uncertified_teacher)
    assert_not_includes teachers, users(:student)
  end

  test "should block inappropriate name" do
    user = User.new(name: "bobo", email: "test@test.com", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:name], "não pode conter termos impróprios ou ofensivos"
  end

  test "should block inappropriate availability" do
    user = users(:student)
    user.availability = "Disponível apenas para vai se foder"
    assert_not user.valid?
    assert_includes user.errors[:availability], "não pode conter termos impróprios ou ofensivos"
  end

  test "should block inappropriate experience" do
    user = users(:teacher)
    user.experience = "Tenho experiência em ser um idiota completo"
    assert_not user.valid?
    assert_includes user.errors[:experience], "não pode conter termos impróprios ou ofensivos"
  end

  test "should block inappropriate preferences" do
    user = users(:student)
    user.preferences = "Prefiro aulas com um filho da puta"
    assert_not user.valid?
    assert_includes user.errors[:preferences], "não pode conter termos impróprios ou ofensivos"
  end

  test "validates correct youtube presentation video url formats" do
    teacher = users(:teacher)
    
    valid_urls = [
      "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "https://youtu.be/dQw4w9WgXcQ",
      "https://www.youtube.com/embed/dQw4w9WgXcQ",
      "https://youtube.com/shorts/dQw4w9WgXcQ?feature=share",
      "https://www.youtube.com/watch?feature=shared&v=dQw4w9WgXcQ"
    ]
    
    valid_urls.each do |url|
      teacher.presentation_video_url = url
      assert teacher.valid?, "Expected #{url} to be valid"
      assert_equal "dQw4w9WgXcQ", teacher.youtube_video_id
    end
  end

  test "invalidates incorrect presentation video urls" do
    teacher = users(:teacher)
    
    invalid_urls = [
      "https://www.google.com",
      "random_string",
      "https://youtube.com",
      "https://youtu.be"
    ]
    
    invalid_urls.each do |url|
      teacher.presentation_video_url = url
      assert_not teacher.valid?, "Expected #{url} to be invalid"
      assert_includes teacher.errors[:presentation_video_url], "deve ser um link válido do YouTube"
    end
  end

  test "pcd defaults to false and can be set to true" do
    user = User.new(name: "Novo Usuario", email: "pcd@test.com", password: "password", phone: "11999999999", cpf: "12345678902")
    assert_equal false, user.pcd
    user.pcd = true
    assert_equal true, user.pcd
  end
end

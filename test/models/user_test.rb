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
end

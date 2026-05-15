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
    teacher = User.new(name: "Prof", email: "p@t.com", password: "pw", role: :teacher)
    assert_not teacher.valid?
    teacher.certificate_url = "http://link.com"
    assert teacher.valid?
  end

  test "certified_teachers scope only returns certified teachers" do
    teachers = User.certified_teachers
    assert_includes teachers, users(:teacher)
    assert_not_includes teachers, users(:uncertified_teacher)
    assert_not_includes teachers, users(:student)
  end
end

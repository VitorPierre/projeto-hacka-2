require "test_helper"

class PcdFlowTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
    @teacher = users(:teacher)
  end

  test "student registration with pcd option checked" do
    get new_user_path(role: "student")
    assert_response :success
    assert_select "input[type=checkbox][name='user[pcd]']"

    post users_path, params: {
      user: {
        name: "Novo Aluno PcD",
        email: "pcd_student@test.com",
        password: "password123",
        role: "student",
        phone: "11999999999",
        cpf: "99999999901",
        pcd: "1",
        terms_acceptance: "1"
      }
    }

    user = User.find_by(email: "pcd_student@test.com")
    assert user
    assert_equal true, user.pcd
    assert_redirected_to student_path(user)

    follow_redirect!
    assert_select "span", text: /Pessoa com Deficiência \(PcD\)/
  end

  test "teacher registration with pcd option checked" do
    get new_user_path(role: "teacher")
    assert_response :success
    assert_select "input[type=checkbox][name='user[pcd]']"

    post users_path, params: {
      user: {
        name: "Novo Prof PcD",
        email: "pcd_teacher@test.com",
        password: "password123",
        role: "teacher",
        phone: "11999999999",
        cpf: "99999999902",
        education_level: "technical",
        certificate_url: "http://certificado.com/pcd",
        subject_ids: [subjects(:math).id],
        pcd: "1",
        terms_acceptance: "1"
      }
    }

    user = User.find_by(email: "pcd_teacher@test.com")
    assert user
    assert_equal true, user.pcd
    assert_redirected_to teacher_path(user)

    follow_redirect!
    assert_select "span", text: /Pessoa com Deficiência \(PcD\)/
  end

  test "user can edit profile and change pcd status" do
    post login_path, params: { email: @student.email, password: "senha123" }

    get edit_user_path(@student)
    assert_response :success
    assert_select "input[type=checkbox][name='user[pcd]']"

    patch user_path(@student), params: {
      user: {
        pcd: "1"
      }
    }

    @student.reload
    assert_equal true, @student.pcd
    assert_redirected_to student_path(@student)

    # Now disable it
    patch user_path(@student), params: {
      user: {
        pcd: "0"
      }
    }

    @student.reload
    assert_equal false, @student.pcd
  end

  test "pcd status is visible on available lists" do
    @student.update!(pcd: true)
    @teacher.update!(pcd: true)

    # Login as student to see teachers list
    post login_path, params: { email: @student.email, password: "senha123" }
    get teachers_path
    assert_response :success
    # There should be a PcD tag on the teacher card
    assert_select "span[title='Pessoa com Deficiência']", text: "PcD"

    # Logout and login as teacher to see students list
    delete logout_path
    post login_path, params: { email: @teacher.email, password: "senha123" }
    get students_path
    assert_response :success
    # There should be a PcD tag on the student card
    assert_select "span[title='Pessoa com Deficiência']", text: "PcD"
  end
end

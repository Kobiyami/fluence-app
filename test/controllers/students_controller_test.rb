require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get students_url
    assert_response :success
  end

  test "should get show" do
    get student_url(students(:one))
    assert_response :success
  end

  test "should get login_form" do
    get login_url
    assert_response :success
  end

  test "should redirect to student on valid login_check" do
    student = students(:one)
    post login_url, params: { code: student.code }
    assert_redirected_to student_path(student)
  end

  test "should reject invalid login_check" do
    post login_url, params: { code: "wrong-code" }
    assert_response :unprocessable_entity
  end
end

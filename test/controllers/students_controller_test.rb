require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get students_index_url
    assert_response :success
  end

  test "should get show" do
    get students_show_url
    assert_response :success
  end

  test "should get login_form" do
    get students_login_form_url
    assert_response :success
  end

  test "should get login_check" do
    get students_login_check_url
    assert_response :success
  end
end

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sessions_new_url
    assert_response :success
  end

  test "should get start" do
    get sessions_start_url
    assert_response :success
  end

  test "should get stop" do
    get sessions_stop_url
    assert_response :success
  end

  test "should get show" do
    get sessions_show_url
    assert_response :success
  end
end

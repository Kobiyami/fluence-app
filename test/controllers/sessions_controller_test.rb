require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_url, params: { student_id: students(:one).id, reading_text_id: reading_texts(:one).id }
    assert_response :success
  end

  test "should start" do
    post sessions_start_url, params: { student_id: students(:one).id, reading_text_id: reading_texts(:one).id }
    assert_response :success
  end

  test "should stop" do
    session = sessions(:one)
    post sessions_stop_url, params: { session_id: session.id, duration_seconds: 42, aborted: "true" }
    assert_redirected_to session_path(session)
  end

  test "should get show" do
    get session_url(sessions(:one))
    assert_response :success
  end
end

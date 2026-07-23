require "test_helper"

class MotOutilExercisesControllerTest < ActionDispatch::IntegrationTest
  test "should get play" do
    get play_mot_outils_url, params: { student_id: students(:one).id }
    assert_response :success
  end
end

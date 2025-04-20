require "test_helper"

class ExerciseLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get exercise_logs_create_url
    assert_response :success
  end

  test "should get update" do
    get exercise_logs_update_url
    assert_response :success
  end

  test "should get destroy" do
    get exercise_logs_destroy_url
    assert_response :success
  end
end

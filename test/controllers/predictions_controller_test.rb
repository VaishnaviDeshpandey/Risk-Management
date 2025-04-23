require "test_helper"

class PredictionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get predictions_index_url
    assert_response :success
  end

  test "should get show" do
    get predictions_show_url
    assert_response :success
  end

  test "should get new" do
    get predictions_new_url
    assert_response :success
  end

  test "should get edit" do
    get predictions_edit_url
    assert_response :success
  end
end

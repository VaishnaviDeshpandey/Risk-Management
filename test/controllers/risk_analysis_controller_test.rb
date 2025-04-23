require "test_helper"

class RiskAnalysisControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get risk_analysis_index_url
    assert_response :success
  end

  test "should get show" do
    get risk_analysis_show_url
    assert_response :success
  end

  test "should get new" do
    get risk_analysis_new_url
    assert_response :success
  end

  test "should get create" do
    get risk_analysis_create_url
    assert_response :success
  end

  test "should get edit" do
    get risk_analysis_edit_url
    assert_response :success
  end

  test "should get update" do
    get risk_analysis_update_url
    assert_response :success
  end

  test "should get destroy" do
    get risk_analysis_destroy_url
    assert_response :success
  end
end

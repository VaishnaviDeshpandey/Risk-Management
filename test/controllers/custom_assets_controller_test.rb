require "test_helper"

class CustomAssetsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get custom_assets_index_url
    assert_response :success
  end

  test "should get show" do
    get custom_assets_show_url
    assert_response :success
  end

  test "should get new" do
    get custom_assets_new_url
    assert_response :success
  end

  test "should get create" do
    get custom_assets_create_url
    assert_response :success
  end

  test "should get edit" do
    get custom_assets_edit_url
    assert_response :success
  end

  test "should get update" do
    get custom_assets_update_url
    assert_response :success
  end

  test "should get destroy" do
    get custom_assets_destroy_url
    assert_response :success
  end
end

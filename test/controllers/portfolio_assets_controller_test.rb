require "test_helper"

class PortfolioAssetsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get portfolio_assets_create_url
    assert_response :success
  end

  test "should get update" do
    get portfolio_assets_update_url
    assert_response :success
  end

  test "should get destroy" do
    get portfolio_assets_destroy_url
    assert_response :success
  end
end

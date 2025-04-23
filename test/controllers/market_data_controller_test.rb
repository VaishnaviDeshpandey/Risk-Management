require "test_helper"

class MarketDataControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get market_data_index_url
    assert_response :success
  end

  test "should get show" do
    get market_data_show_url
    assert_response :success
  end

  test "should get new" do
    get market_data_new_url
    assert_response :success
  end

  test "should get edit" do
    get market_data_edit_url
    assert_response :success
  end
end

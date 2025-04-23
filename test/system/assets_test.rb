require "application_system_test_case"

class AssetsTest < ApplicationSystemTestCase
  setup do
    @asset = assets(:one)
  end

  test "visiting the index" do
    visit assets_url
    assert_selector "h1", text: "Assets"
  end

  test "should create asset" do
    visit assets_url
    click_on "New asset"

    fill_in "Asset type", with: @asset.asset_type
    fill_in "Name", with: @asset.name
    fill_in "Price", with: @asset.price
    fill_in "Sector", with: @asset.sector
    fill_in "Symbol", with: @asset.symbol
    click_on "Create Asset"

    assert_text "Asset was successfully created"
    click_on "Back"
  end

  test "should update Asset" do
    visit asset_url(@asset)
    click_on "Edit this asset", match: :first

    fill_in "Asset type", with: @asset.asset_type
    fill_in "Name", with: @asset.name
    fill_in "Price", with: @asset.price
    fill_in "Sector", with: @asset.sector
    fill_in "Symbol", with: @asset.symbol
    click_on "Update Asset"

    assert_text "Asset was successfully updated"
    click_on "Back"
  end

  test "should destroy Asset" do
    visit asset_url(@asset)
    click_on "Destroy this asset", match: :first

    assert_text "Asset was successfully destroyed"
  end
end

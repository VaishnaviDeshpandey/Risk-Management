class CustomAssetsController < ApplicationController
  before_action :set_custom_asset, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @custom_assets = CustomAsset.all
  end

  def show
  end

  def new
    @custom_asset = CustomAsset.new
  end

  def create
    @custom_asset = CustomAsset.new(custom_asset_params)
    if @custom_asset.save
      redirect_to @custom_asset, notice: "Custom asset created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @custom_asset.update(custom_asset_params)
      redirect_to @custom_asset, notice: "Custom asset updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @custom_asset.destroy
    redirect_to custom_assets_url, notice: "Custom asset deleted."
  end

  private

  def set_custom_asset
    @custom_asset = CustomAsset.find(params[:id])
  end

  def custom_asset_params
    params.require(:custom_asset).permit(:symbol, :name, :asset_type, :sector, :price)
  end
end


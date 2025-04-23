class PortfolioAssetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio

  def create
    @asset = @portfolio.portfolio_assets.find_or_initialize_by(custom_asset_id: params[:portfolio_asset][:custom_asset_id])
    @asset.quantity += params[:portfolio_asset][:quantity].to_i
    if @asset.save
      redirect_to @portfolio, notice: "Asset added to portfolio."
    else
      redirect_to @portfolio, alert: "Failed to add asset."
    end
  end

  def update
    @asset = @portfolio.portfolio_assets.find(params[:id])
    if @asset.update(quantity: params[:portfolio_asset][:quantity])
      redirect_to @portfolio, notice: "Asset updated."
    else
      redirect_to @portfolio, alert: "Failed to update asset."
    end
  end

  def destroy
    @asset = @portfolio.portfolio_assets.find(params[:id])
    @asset.destroy
    redirect_to @portfolio, notice: "Asset removed."
  end

  private

  def set_portfolio
    @portfolio = current_user.portfolios.find(params[:portfolio_id])
  end
end

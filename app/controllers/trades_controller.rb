class TradesController < ApplicationController
  before_action :set_trade, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @trades = Trade.all
  end

  def show
  end

  def new
    user_portfolios = current_user.portfolios
    available_assets = CustomAsset.all
  
    if user_portfolios.empty?
      redirect_to new_portfolio_path, alert: 'You need to create a portfolio before making a trade.'
      return
    elsif available_assets.empty?
      redirect_to new_custom_asset_path, alert: 'You need to create an asset before making a trade.'
      return
    end
  
    @trade = Trade.new
    @trade.portfolio = user_portfolios.first
    @trade.custom_asset = available_assets.first
  end

  def create
    @trade = Trade.new(trade_params)
    @trade.user = current_user # ✅ Explicitly set the user
  
    if @trade.save
      redirect_to @trade, notice: 'Trade was successfully created.'
    else
      render :new
    end
  end
  
  def edit
  end

  def update
    if @trade.update(trade_params)
      redirect_to @trade, notice: 'Trade was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @trade.destroy
    redirect_to trades_url, notice: 'Trade was successfully destroyed.'
  end

  private

  def set_trade
    @trade = Trade.find(params[:id])
  end

  def trade_params
    params.require(:trade).permit(:user_id, :custom_asset_id, :portfolio_id, :trade_type, :quantity, :price, :executed_at)
  end
end


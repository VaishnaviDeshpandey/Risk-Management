# app/controllers/portfolios_controller.rb
class PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_portfolio, only: [:show, :edit, :update, :destroy, :assess_risk]

  def index
    @portfolios = current_user.portfolios
  end

  def show
    if @portfolio.var_value.nil? || @portfolio.cvar_value.nil?
      unless Sidekiq::Queue.new.any? { |job| job.args.first == @portfolio.id }
        RunPortfolioRiskAssessmentJob.perform_async(@portfolio.id)
        flash[:notice] = "Risk assessment for the portfolio has been initiated."
      end
    end
  end
  

  def assess_risk
    # Trigger the risk assessment (same logic as show)
    RunPortfolioRiskAssessmentJob.perform_async(@portfolio.id)
    redirect_to @portfolio, notice: "Risk assessment for the portfolio has been initiated."
  end

  def new
    @portfolio = current_user.portfolios.build
  end

  def create
    @portfolio = current_user.portfolios.build(portfolio_params)
    if @portfolio.save
      redirect_to @portfolio, notice: "Portfolio created successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @portfolio.update(portfolio_params)
      redirect_to @portfolio, notice: "Portfolio updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @portfolio.destroy
    redirect_to portfolios_path, notice: "Portfolio deleted."
  end

  private

  def set_portfolio
    @portfolio = current_user.portfolios.find(params[:id])
  end

  def portfolio_params
    params.require(:portfolio).permit(:name)
  end
end

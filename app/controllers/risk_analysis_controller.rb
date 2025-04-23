class RiskAnalysisController < ApplicationController
  before_action :set_risk_analysis, only: [:show, :edit, :update, :destroy]

  def index
    @risk_analyses = SnowflakeClient.all_risk_analyses
  end

  def show
    # @risk_analysis is set by before_action
  end

  def new
    @risk_analysis = SnowflakeClient.new_risk_analysis
  end

  def create
    @risk_analysis = SnowflakeClient.create_risk_analysis(risk_analysis_params)
    if @risk_analysis && @risk_analysis[:id].present?
      redirect_to risk_analysis_path(@risk_analysis[:id]), notice: 'Risk analysis created.'
    else
      redirect_to risk_analysis_index_path, alert: "Risk analysis could not be created."
    end
  end

  def edit
    # @risk_analysis is set by before_action
  end

  def update
    @risk_analysis = SnowflakeClient.update_risk_analysis(params[:id], risk_analysis_params)
    redirect_to risk_analysis_path(@risk_analysis[:id]), notice: 'Risk analysis updated.'
  end

  def destroy
    SnowflakeClient.delete_risk_analysis(params[:id])
    redirect_to risk_analysis_index_path, notice: 'Risk analysis deleted.'
  end

  private

  def set_risk_analysis
    @risk_analysis = SnowflakeClient.find_risk_analysis(params[:id])
    if @risk_analysis.nil?
      redirect_to risk_analysis_index_path, alert: "Risk analysis not found."
    end
  end

  def risk_analysis_params
    params.require(:risk_analysis).permit(:id, :trade_id, :risk_score, :prediction)
  end
end

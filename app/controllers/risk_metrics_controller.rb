class RiskMetricsController < ApplicationController
  before_action :set_risk_metric, only: [:show, :destroy]

  def index
    all_data = SnowflakeClient.all_risk_metrics

    @all_symbols = all_data.map { |m| m[:symbol] }.uniq.compact.sort
    @symbol      = params[:symbol]&.upcase
    @start_date  = params[:start_date]
    @end_date    = params[:end_date]

    # 🧠 Unified Filtering Block
    filtered = all_data.select do |m|
      symbol_match = @symbol.blank? || m[:symbol].to_s.upcase == @symbol
      start_match  = @start_date.blank? || m[:calculated_at].to_date >= Date.parse(@start_date) rescue true
      end_match    = @end_date.blank? || m[:calculated_at].to_date <= Date.parse(@end_date) rescue true
      symbol_match && start_match && end_match
    end

    # 🔢 Sort for chart
    filtered.sort_by! { |m| m[:calculated_at] }

    # 🧩 Log & Inspect
    Rails.logger.info "FILTERED RESULTS FOR SYMBOL #{@symbol || 'ALL'}: #{filtered.map { |m| [m[:symbol], m[:var_value], m[:calculated_at]] }}"
    Rails.logger.info "FILTERED SIZE: #{filtered.size}"

    @dates = filtered.map { |m| m[:calculated_at].strftime('%Y-%m-%d %H:%M') }
    @vars  = filtered.map { |m| m[:var_value].to_f }
    @cvars = filtered.map { |m| m[:cvar_value].to_f }
    @debug_data = filtered.map { |m| [m[:symbol], m[:var_value], m[:cvar_value], m[:calculated_at]] }
  end

  def show; end

  def create
    result = RunVaRSimulationJob.perform_async(symbol: params[:symbol])
    render json: { status: 'Simulation started', job_id: result }
  end

  def destroy
    SnowflakeClient.delete_risk_metric(@risk_metric[:id])
    render json: { status: 'Risk Metric deleted' }
  end

  private

  def set_risk_metric
    @risk_metric = SnowflakeClient.find_risk_metric(params[:id])
    render json: { error: 'Risk Metric not found' }, status: :not_found unless @risk_metric
  end
end

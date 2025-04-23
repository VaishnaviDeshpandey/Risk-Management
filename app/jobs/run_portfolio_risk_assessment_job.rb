class RunPortfolioRiskAssessmentJob
  include Sidekiq::Job

  def perform(portfolio_id)
    portfolio = Portfolio.find(portfolio_id)
    assets = portfolio.custom_assets

    results = assets.map do |asset|
      Thread.new do
        {
          asset_id: asset.id,
          symbol: asset.symbol,
          var_value: simulate_risk_for_asset(asset)
        }
      end
    end.map(&:value) # Join threads and collect return values

    aggregate_portfolio_risk(portfolio, results)
  end

  private

  def simulate_risk_for_asset(asset)
    symbol = asset.symbol
    prices = fetch_historical_prices(symbol)
    return 0.0 if prices.nil? || prices.size < 30

    result = Simulations::MonteCarloVar.new(
      prices: prices,
      simulations: 10_000,
      days: 1,
      confidence: 0.95
    ).run

    calculated_at = Time.now.utc.iso8601
    save_risk_metrics(symbol, result[:var], result[:cvar], calculated_at)

    result[:var]
  end

  def fetch_historical_prices(symbol)
    # Replace with actual Snowflake/API data fetch
    (1..60).map { 100 + rand(-5.0..5.0) }
  end

  def save_risk_metrics(symbol, var, cvar, calculated_at)
    client = SnowflakeClient.new
    SnowflakeClient.create_risk_metric( # ✅ Works
      symbol: symbol,
      var_value: var,
      cvar_value: cvar,
      calculated_at: calculated_at
    )
  end

  def aggregate_portfolio_risk(portfolio, asset_results)
    total_var = asset_results.sum { |res| res[:var_value].to_f }

    portfolio.update!(
      var_value: total_var,
      updated_at: Time.current
    )
  end
end


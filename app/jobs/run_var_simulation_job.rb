class RunVarSimulationJob
  include Sidekiq::Job

  def perform(args)
    symbol      = args['symbol']
    simulations = args['simulations'] || 10_000
    days        = args['days'] || 1
    confidence  = args['confidence'] || 0.95

    snowflake = SnowflakeClient.new
    prices = fetch_historical_prices(snowflake, symbol)

    Rails.logger.info "[RunVarSimulationJob] #{symbol}: Retrieved #{prices.size} prices"

    if prices.nil? || prices.size < 30 || prices.uniq.size < 2
      Rails.logger.warn("[RunVarSimulationJob] Skipping simulation for #{symbol}: insufficient or flat price data")
      return
    end

    result = Simulations::MonteCarloVar.new(
      prices: prices,
      simulations: simulations,
      days: days,
      confidence: confidence
    ).run

    Rails.logger.info "[RunVarSimulationJob] #{symbol}: Simulation Result => VaR: #{result[:var]}, CVaR: #{result[:cvar]}"
    save_risk_metrics(snowflake, symbol, result[:var], result[:cvar])
  end

  private

  def fetch_historical_prices(snowflake, symbol)
    data = snowflake.query("
      SELECT close FROM market_data
      WHERE symbol = '#{symbol}'
      ORDER BY date ASC
    ").map { |row| row[:close].to_f }  # ✅ FIXED from 'CLOSE' to :close

    filtered = data.compact.reject { |p| p <= 0 }
    Rails.logger.info("[RunVarSimulationJob] Valid price sample: #{filtered.first(5)}")
    filtered
  end

  def save_risk_metrics(snowflake, symbol, var, cvar)
    timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    Rails.logger.info "[RunVarSimulationJob] Saving metrics for #{symbol} at #{timestamp}: VaR=#{var}, CVaR=#{cvar}"

    snowflake.insert('risk_metrics', {
      symbol: symbol,
      calculated_at: timestamp,
      var_value: var,
      cvar_value: cvar
    })
  end
end

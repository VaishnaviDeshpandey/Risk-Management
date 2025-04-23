class InsertPredictionJob
  include Sidekiq::Job

  def perform(args)
    symbol = args["symbol"]
    predicted_price = args["predicted_price"]
    risk_level = args["risk_level"]
    raw_time = args["prediction_time"]

    prediction_time =
      if raw_time.is_a?(Numeric)
        Time.at(raw_time / 1000.0).utc
      elsif raw_time.is_a?(String) && raw_time.match?(/^\d+$/)
        Time.at(raw_time.to_i / 1000.0).utc
      elsif raw_time.present?
        Time.parse(raw_time).utc rescue Time.now.utc
      else
        Time.now.utc
      end

    prediction_time_str = prediction_time.iso8601

    # Prevent duplicate insert
    existing = SnowflakeClient.all_predictions.find do |p|
      p[:symbol] == symbol && p[:forecast_date].to_s == prediction_time_str
    end

    return if existing # Don't insert if already exists

    # Insert if unique
    SnowflakeClient.insert_prediction(symbol, predicted_price, risk_level, prediction_time_str)
  end
end


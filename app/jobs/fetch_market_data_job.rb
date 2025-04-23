class FetchMarketDataJob < ApplicationJob
  queue_as :default

  def perform(symbols)
    symbols = Array(symbols).map(&:upcase)

    client = BasicYahooFinance::Query.new
    response = client.quotes(symbols)

    symbols.each do |symbol|
      data = response[symbol]
      unless data
        Rails.logger.error("No data returned for symbol: #{symbol}")
        next
      end

      Rails.logger.info("Full response for #{symbol}: #{data.inspect}")

      unless data["regularMarketPrice"]
        Rails.logger.error("No regular market price for symbol: #{symbol}")
        next
      end

      begin
        # Fetch market data and update CustomAsset prices
        market_data = {
          symbol: symbol,
          open: data["regularMarketOpen"].to_f,
          high: data["regularMarketDayHigh"].to_f,
          low: data["regularMarketDayLow"].to_f,
          close: data["regularMarketPreviousClose"].to_f,
          volume: data["regularMarketVolume"].to_i,
          date: Time.at(data["regularMarketTime"]).utc.to_date.to_s
        }

        Rails.logger.info("Inserting market data for #{symbol}: #{market_data}")
        SnowflakeClient.insert_market_data_with_id(market_data)

        # Update the price in the CustomAsset model
        custom_asset = CustomAsset.find_by(symbol: symbol)
        if custom_asset
          custom_asset.update(price: market_data[:close]) # Update the price field
          Rails.logger.info("Updated price for #{symbol}: #{market_data[:close]}")
        else
          Rails.logger.error("CustomAsset not found for symbol: #{symbol}")
        end

        # Predict based on the fetched market data
        prediction = PredictionEngine.predict(symbol, market_data)

        # Save prediction to Snowflake
        Rails.logger.info("Inserting prediction for #{symbol}: #{prediction}")
        SnowflakeClient.insert_prediction(prediction)

      rescue => e
        Rails.logger.error("Error processing market data for #{symbol}: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end
  rescue => e
    Rails.logger.error("FetchMarketDataJob failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
  end
end

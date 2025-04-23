require 'httparty'
require 'json'

class FetchHistoricalDataJob < ApplicationJob
  queue_as :default

  def perform(symbol)
    puts "🚀 Starting FetchHistoricalDataJob for #{symbol}"
    symbol = symbol.upcase
    api_key = ENV['ALPHAVANTAGE_API_KEY']
    url = "https://www.alphavantage.co/query"
    params = {
      function: 'TIME_SERIES_DAILY',
      symbol: symbol,
      outputsize: 'full',
      apikey: api_key
    }

    begin
      response = HTTParty.get(url, query: params)
      puts "🔍 API response status: #{response.code}"

      parsed = JSON.parse(response.body)
      puts "📦 Parsed response keys: #{parsed.keys}"

      if parsed["Error Message"]
        puts "❌ Alpha Vantage Error: #{parsed["Error Message"]}"
        return
      end

      data = parsed['Time Series (Daily)']

      if data.nil?
        puts "❌ No 'Time Series (Daily)' in response for #{symbol}"
        puts parsed.inspect
        return
      end

      count = 0
      data.each do |date, values|
        count += 1
        puts "📈 Processing #{symbol} on #{date}"
        market_data = {
          symbol: symbol,
          date: date,
          open: values['1. open'].to_f,
          high: values['2. high'].to_f,
          low: values['3. low'].to_f,
          close: values['4. close'].to_f,
          volume: values['5. volume'].to_i
        }

        SnowflakeClient.insert_market_data_with_id(market_data)
      end

      puts "✅ Fetched and saved #{count} records for #{symbol}"
    rescue => e
      puts "❌ Error in FetchHistoricalDataJob for #{symbol}: #{e.message}"
    end
  end
end

# lib/tasks/import_market_data.rake

namespace :market_data do
  desc "Fetch live market data from Yahoo for selected symbols"
  task fetch: :environment do
    symbols = %w[AAPL TSLA GOOG MSFT NVDA META]
    puts "📈 Enqueuing FetchMarketDataJob for: #{symbols.join(', ')}"
    FetchMarketDataJob.perform_later(symbols)
  end
end

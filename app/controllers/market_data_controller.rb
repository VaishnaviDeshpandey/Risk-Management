require 'ostruct'

class MarketDataController < ApplicationController
  def index
    @symbol = params[:symbol]&.upcase
    @view = params[:view] || 'latest'

    all_data = SnowflakeClient.all_market_data

    filtered = all_data.select do |d|
      @symbol.nil? || d[:symbol] == @symbol
    end

    # Convert ODBC timestamp to Ruby Date
    filtered.each do |d|
      d[:parsed_date] = Date.parse(d[:date].to_s) rescue nil
    end

    cutoff_date = 30.days.ago.to_date

    @market_data =
      if @view == 'historical'
        filtered.select { |d| d[:parsed_date] && d[:parsed_date] < cutoff_date }
      else
        filtered.select { |d| d[:parsed_date] && d[:parsed_date] >= cutoff_date }
      end
  end

  def show
    @data = OpenStruct.new(SnowflakeClient.find_market_data(params[:id]))
  end

  def new
    @data = OpenStruct.new(
      symbol: '',
      date: Time.zone.today,
      open: 0.0,
      high: 0.0,
      low: 0.0,
      close: 0.0,
      volume: 0
    )
  end

  def create
    # Simulate create by fetching from external service
    symbol = params[:market_data][:symbol].upcase
    FetchMarketDataJob.perform_later(symbol)

    redirect_to market_data_index_path, notice: "Fetching market data for #{symbol}..."
  end

  def edit
    record = SnowflakeClient.find_market_data(params[:id])
    @data = OpenStruct.new(record)
  end

  def update
    # Update record using SnowflakeClient
    SnowflakeClient.update_market_data(params[:id], market_data_params)

    redirect_to market_datum_path(params[:id]), notice: "Market data updated!"
  end

  def destroy
    SnowflakeClient.delete_market_data(params[:id])
    redirect_to market_data_path, notice: "Market data deleted."
  end

  def fetch
    symbol = params[:symbol].presence || 'AAPL'
    FetchMarketDataJob.perform_later(symbol)

    redirect_to market_data_path, notice: "Data fetch for #{symbol} has started!"
  end

  private

  def market_data_params
    params.require(:market_data).permit(:symbol, :date, :open, :high, :low, :close, :volume)
  end
end

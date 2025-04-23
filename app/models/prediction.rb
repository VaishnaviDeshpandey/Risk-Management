class Prediction
  # You can define useful helpers or validations here
  attr_accessor :id, :symbol, :predicted_price, :risk_level, :forecast_date

  def initialize(attrs = {})
    @id = attrs[:id]
    @symbol = attrs[:symbol]
    @predicted_price = attrs[:predicted_price]
    @risk_level = attrs[:risk_level]
    @forecast_date = attrs[:forecast_date]
  end
end

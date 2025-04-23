# app/models/trade.rb
class Trade < ApplicationRecord
  belongs_to :user
  belongs_to :custom_asset
  belongs_to :portfolio, optional: true

  validates :trade_type, presence: true, inclusion: { in: %w[buy sell], message: "must be 'buy' or 'sell'" }
  validates :quantity, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :executed_at, presence: true
end
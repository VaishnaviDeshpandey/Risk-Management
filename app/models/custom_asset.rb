class CustomAsset < ApplicationRecord
  has_many :portfolio_assets, dependent: :destroy
  has_many :portfolios, through: :portfolio_assets
  has_many :users, through: :portfolios  
  before_save :upcase_symbol
  has_many :trades

  validates :symbol, presence: { message: "Symbol is required" }, uniqueness: { message: "Symbol must be unique" }
  validates :name, presence: { message: "Name is required" }
  validates :asset_type, presence: { message: "Asset type is required" }, inclusion: { in: ["Stock", "Crypto", "Forex", "Commodity"], message: "Asset type must be one of Stock, Crypto, Forex, or Commodity" }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, message: "Price must be a non-negative number" }

  private

  def upcase_symbol
    self.symbol = symbol.upcase if symbol.present?
  end
end


class PortfolioAsset < ApplicationRecord
  belongs_to :portfolio
  belongs_to :custom_asset

  validates :quantity, presence: true, numericality: { greater_than: 0 }
end

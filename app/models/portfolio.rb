class Portfolio < ApplicationRecord
  belongs_to :user
  has_many :portfolio_assets, dependent: :destroy
  has_many :custom_assets, through: :portfolio_assets
  has_many :trades

  validates :name, presence: true

  def display_name
    "#{user&.username || 'Unknown'} - Portfolio ##{id}"
  end

  def asset_symbols
    custom_assets.map(&:symbol)
  end
end



# app/models/risk_analysis.rb
class RiskAnalysis < SnowflakeBase
  self.table_name = 'risk_analysis'
  self.primary_key = 'id'

  attribute :id, :string
  attribute :trade_id, :integer
  attribute :risk_score, :float
  attribute :prediction, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  validates :trade_id, presence: true
  validates :risk_score, numericality: true, allow_nil: true
  validates :prediction, inclusion: { in: %w[low medium high], allow_blank: true }

  scope :high_risk, -> { where("risk_score > 0.8") }
  scope :recent, -> { order(created_at: :desc) }

  def high_risk?
    risk_score.to_f > 0.8
  end
end

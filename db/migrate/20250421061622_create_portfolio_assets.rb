class CreatePortfolioAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolio_assets do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :custom_asset, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end
end

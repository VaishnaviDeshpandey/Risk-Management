class CreateTrades < ActiveRecord::Migration[8.0]
  def change
    create_table :trades do |t|
      t.references :user, null: false, foreign_key: true
      t.references :custom_asset, null: false, foreign_key: true
      t.references :portfolio, foreign_key: true
      t.string :trade_type, null: false
      t.integer :quantity, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.datetime :executed_at, null: false

      t.timestamps
    end
  end
end

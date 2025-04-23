class CreateCustomAssets < ActiveRecord::Migration[8.0]
  def change
    create_table :custom_assets do |t|
      t.string :symbol, null: false
      t.string :name, null: false
      t.string :asset_type, null: false
      t.string :sector
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end

    add_index :custom_assets, :symbol, unique: true
  end
end

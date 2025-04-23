class CreatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false  # Optional: give the portfolio a name

      t.timestamps
    end
  end
end

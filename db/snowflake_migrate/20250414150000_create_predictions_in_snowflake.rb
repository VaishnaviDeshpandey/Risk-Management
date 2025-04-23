require Rails.root.join("lib/snowflake_migrations/base")

class CreatePredictionsInSnowflake < SnowflakeMigrations::Base
  def up
    execute <<-SQL
      CREATE TABLE IF NOT EXISTS ai_risk_db.public.predictions (
        id INTEGER AUTOINCREMENT,
        symbol STRING,
        predicted_price DECIMAL(10,2),
        risk_level STRING,
        forecast_date TIMESTAMP,
        created_at TIMESTAMP,
        updated_at TIMESTAMP
      );
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS ai_risk_db.public.predictions;"
  end
end

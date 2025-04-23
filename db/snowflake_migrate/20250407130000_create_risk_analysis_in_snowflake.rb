require Rails.root.join("lib/snowflake_migrations/base")

class CreateRiskAnalysisInSnowflake < SnowflakeMigrations::Base
  def up
    # Then create
    execute <<-SQL
    CREATE TABLE IF NOT EXISTS ai_risk_db.public.risk_analysis (
      id INTEGER AUTOINCREMENT,
      trade_id INTEGER,
      risk_score FLOAT,
      prediction TEXT,
      created_at TIMESTAMP,
      updated_at TIMESTAMP
    );
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS ai_risk_db.public.risk_analysis;"
  end  
end


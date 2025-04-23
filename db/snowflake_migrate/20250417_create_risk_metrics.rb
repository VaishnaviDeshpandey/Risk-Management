# db/snowflake_migrate/20250417_create_risk_metrics.rb
class CreateRiskMetrics < SnowflakeMigrations::Base
  def up
    execute "USE SCHEMA AI_RISK_DB.PUBLIC;"

    execute <<~SQL
      CREATE TABLE IF NOT EXISTS AI_RISK_DB.PUBLIC.risk_metrics (
        id INTEGER AUTOINCREMENT PRIMARY KEY,
        symbol VARCHAR,
        calculated_at TIMESTAMP,
        var_value FLOAT,
        cvar_value FLOAT
      );
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS AI_RISK_DB.PUBLIC.risk_metrics;"
  end
end

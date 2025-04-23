# db/snowflake_migrate/20250408110000_create_market_data.rb
class CreateMarketData < SnowflakeMigrations::Base
  def up
    execute <<-SQL
      CREATE TABLE IF NOT EXISTS AI_RISK_DB.PUBLIC.MARKET_DATA (
        id INTEGER AUTOINCREMENT PRIMARY KEY,
        symbol STRING,
        date TIMESTAMP,
        open DECIMAL(10,2),
        high DECIMAL(10,2),
        low DECIMAL(10,2),
        close DECIMAL(10,2),
        volume INTEGER
      );
    SQL
  end

  def down
    execute "DROP TABLE IF EXISTS AI_RISK_DB.PUBLIC.MARKET_DATA;"
  end
end


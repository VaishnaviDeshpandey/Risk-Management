require 'odbc'
require 'time'

class SnowflakeClient
  # ===================== CLASS METHODS =====================
  class << self
    def connection
      @connection ||= ODBC.connect('SnowflakeDSN', 'Vaishnavi2001', 'Vaishnavi@2001')
    end

    def parse_timestamps(row)
      [:created_at, :updated_at, :forecast_date, :calculated_at].each do |key|
        row[key] = Time.parse(row[key].to_s) if row[key]
      end
      row
    end

    # ========== RISK ANALYSIS ==========
    def all_risk_analyses
      stmt = connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.RISK_ANALYSIS ORDER BY created_at DESC")
      results = []
      while row = stmt.fetch_hash
        results << parse_timestamps(row.transform_keys(&:downcase).transform_keys(&:to_sym).slice(:id, :trade_id, :risk_score, :prediction, :created_at, :updated_at))
      end
      results
    end

    def find_risk_analysis(id)
      stmt = connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.RISK_ANALYSIS WHERE id = #{id}")
      row = stmt.fetch_hash
      row&.transform_keys(&:downcase)&.symbolize_keys&.then { parse_timestamps(_1) }
    end

    def new_risk_analysis
      {
        trade_id: nil,
        risk_score: nil,
        prediction: "",
        created_at: Time.now,
        updated_at: Time.now
      }
    end

    def create_risk_analysis(attrs)
      now = Time.now.utc.iso8601
      sql = <<-SQL
        INSERT INTO AI_RISK_DB.PUBLIC.RISK_ANALYSIS (trade_id, risk_score, prediction, created_at, updated_at)
        VALUES (#{attrs[:trade_id]}, #{attrs[:risk_score]}, '#{attrs[:prediction]}', '#{now}', '#{now}');
      SQL
      connection.run(sql)
      connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.RISK_ANALYSIS WHERE trade_id = #{attrs[:trade_id]} AND prediction = '#{attrs[:prediction]}' ORDER BY created_at DESC LIMIT 1").fetch_hash&.transform_keys(&:downcase)&.symbolize_keys
    end

    def update_risk_analysis(id, attrs)
      now = Time.now.utc.iso8601
      sql = <<-SQL
        UPDATE AI_RISK_DB.PUBLIC.RISK_ANALYSIS
        SET trade_id = #{attrs[:trade_id]},
            risk_score = #{attrs[:risk_score]},
            prediction = '#{attrs[:prediction]}',
            updated_at = '#{now}'
        WHERE id = #{id};
      SQL
      connection.run(sql)
      find_risk_analysis(id)
    end

    def delete_risk_analysis(id)
      connection.run("DELETE FROM AI_RISK_DB.PUBLIC.RISK_ANALYSIS WHERE id = #{id}")
    end

    # ========== PREDICTIONS ==========
    def all_predictions
      stmt = connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.PREDICTIONS ORDER BY forecast_date DESC")
      results = []
      while row = stmt.fetch_hash
        results << parse_timestamps(row.transform_keys(&:downcase).symbolize_keys)
      end
      results
    ensure
      stmt&.drop
    end

    def find_prediction(id)
      stmt = connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.PREDICTIONS WHERE id = #{id}")
      row = stmt.fetch_hash
      row&.transform_keys(&:downcase)&.symbolize_keys&.then { parse_timestamps(_1) }
    ensure
      stmt&.drop
    end

    def new_prediction
      {
        symbol: '',
        predicted_price: nil,
        risk_level: 'medium',
        forecast_date: Time.now
      }
    end

    def next_prediction_id
      stmt = connection.run("SELECT COALESCE(MAX(id), 0) + 1 AS next_id FROM AI_RISK_DB.PUBLIC.PREDICTIONS")
      row = stmt.fetch_hash
      row ? row['NEXT_ID'].to_i : 1
    ensure
      stmt&.drop
    end

    def create_prediction(attrs)
      id = next_prediction_id
      sql = <<~SQL
        INSERT INTO AI_RISK_DB.PUBLIC.PREDICTIONS (id, symbol, predicted_price, risk_level, forecast_date)
        VALUES (#{id}, '#{attrs[:symbol]}', #{attrs[:predicted_price]}, '#{attrs[:risk_level]}', '#{Time.parse(attrs[:forecast_date].to_s).utc.iso8601}');
      SQL
      connection.run(sql)
      find_prediction(id)
    end

    def update_prediction(id, attrs)
      sql = <<~SQL
        UPDATE AI_RISK_DB.PUBLIC.PREDICTIONS
        SET symbol = '#{attrs[:symbol]}',
            predicted_price = #{attrs[:predicted_price]},
            risk_level = '#{attrs[:risk_level]}',
            forecast_date = '#{Time.parse(attrs[:forecast_date].to_s).utc.iso8601}'
        WHERE id = #{id};
      SQL
      connection.run(sql)
      find_prediction(id)
    end

    # ✅ Delegator for instance-based insert_prediction
    def insert_prediction(symbol, predicted_price, risk_level, prediction_time)
      new.insert_prediction(symbol, predicted_price, risk_level, prediction_time)
    end    

    # ========== MARKET DATA ==========
    def all_market_data
      stmt = connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.MARKET_DATA ORDER BY date DESC")
      results = []
      while row = stmt.fetch_hash
        results << row.transform_keys(&:downcase).symbolize_keys
      end
      results
    ensure
      stmt&.drop
    end

    def find_closing_prices(symbol)
      stmt = connection.run("SELECT close FROM AI_RISK_DB.PUBLIC.MARKET_DATA WHERE symbol = '#{symbol.upcase}' ORDER BY date ASC")
      results = []
      while row = stmt.fetch_hash
        results << row['CLOSE'].to_f unless row['CLOSE'].to_f.zero?
      end
      results
    ensure
      stmt&.drop
    end

    def next_market_data_id
      stmt = connection.run("SELECT COALESCE(MAX(id), 0) + 1 AS next_id FROM AI_RISK_DB.PUBLIC.MARKET_DATA")
      row = stmt.fetch_hash
      row ? row['NEXT_ID'].to_i : 1
    ensure
      stmt&.drop
    end

    def insert_market_data_with_id(data)
      symbol = data[:symbol]
      date = data[:date]

      stmt = connection.run("SELECT COUNT(*) AS count FROM AI_RISK_DB.PUBLIC.MARKET_DATA WHERE symbol = '#{symbol}' AND date = '#{date}'")
      return if stmt.fetch_hash['COUNT'].to_i > 0

      new_id = next_market_data_id
      insert_stmt = connection.prepare("INSERT INTO AI_RISK_DB.PUBLIC.MARKET_DATA (id, symbol, open, high, low, close, volume, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
      insert_stmt.execute(new_id, data[:symbol], data[:open], data[:high], data[:low], data[:close], data[:volume], data[:date])
    ensure
      stmt&.drop
      insert_stmt&.drop
    end

    def find_market_data(id)
      stmt = connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.MARKET_DATA WHERE id = #{id}")
      row = stmt.fetch_hash
      row&.transform_keys(&:downcase)&.symbolize_keys
    ensure
      stmt&.drop
    end

    def create_market_data(attrs)
      id = next_market_data_id
      sql = <<~SQL
        INSERT INTO AI_RISK_DB.PUBLIC.MARKET_DATA (id, symbol, date, open, high, low, close, volume)
        VALUES (#{id}, '#{attrs[:symbol]}', '#{attrs[:date]}', #{attrs[:open]}, #{attrs[:high]}, #{attrs[:low]}, #{attrs[:close]}, #{attrs[:volume]});
      SQL
      stmt = connection.prepare(sql)
      stmt.execute
      find_market_data(id)
    ensure
      stmt&.drop
    end

    def update_market_data(id, attrs)
      sql = <<~SQL
        UPDATE AI_RISK_DB.PUBLIC.MARKET_DATA
        SET symbol = '#{attrs[:symbol]}',
            date = '#{attrs[:date]}',
            open = #{attrs[:open]},
            high = #{attrs[:high]},
            low = #{attrs[:low]},
            close = #{attrs[:close]},
            volume = #{attrs[:volume]}
        WHERE id = #{id};
      SQL
      stmt = connection.prepare(sql)
      stmt.execute
      find_market_data(id)
    ensure
      stmt&.drop
    end

    def delete_market_data(id)
      stmt = connection.prepare("DELETE FROM AI_RISK_DB.PUBLIC.MARKET_DATA WHERE id = #{id}")
      stmt.execute
    ensure
      stmt&.drop
    end

    # ========== RISK METRICS ==========
    def all_risk_metrics
      stmt = connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.RISK_METRICS ORDER BY calculated_at DESC")
      results = []
      while row = stmt.fetch_hash
        results << parse_timestamps(row.transform_keys(&:downcase).symbolize_keys)
      end
      results
    ensure
      stmt&.drop
    end

    def find_risk_metric(id)
      stmt = connection.run("SELECT * FROM AI_RISK_DB.PUBLIC.RISK_METRICS WHERE id = #{id}")
      row = stmt.fetch_hash
      row&.transform_keys(&:downcase)&.symbolize_keys
    ensure
      stmt&.drop
    end

    def create_risk_metric(attrs)
      calculated_at = if attrs[:calculated_at].is_a?(String)
                        attrs[:calculated_at]
                      else
                        Time.parse(attrs[:calculated_at].to_s).utc.iso8601
                      end
    
      stmt = connection.prepare(<<~SQL)
        INSERT INTO AI_RISK_DB.PUBLIC.RISK_METRICS (symbol, calculated_at, var_value, cvar_value)
        VALUES (?, ?, ?, ?)
      SQL
    
      stmt.execute(
        attrs[:symbol],
        calculated_at,
        attrs[:var_value],
        attrs[:cvar_value]
      )
    
      find_risk_metric_by_symbol_and_time(attrs[:symbol], calculated_at)
    ensure
      stmt&.drop
    end       

    def find_risk_metric_by_symbol_and_time(symbol, timestamp)
      result = query(<<~SQL, [symbol, timestamp])
        SELECT * FROM AI_RISK_DB.PUBLIC.RISK_METRICS
        WHERE symbol = ? AND calculated_at = ?
        LIMIT 1
      SQL
      result.first
    end    

    def delete_risk_metric(id)
      connection.run("DELETE FROM AI_RISK_DB.PUBLIC.RISK_METRICS WHERE id = #{id}")
    end
  end

  # ===================== INSTANCE METHODS =====================
  def query(sql)
    conn = ODBC.connect('SnowflakeDSN', 'Vaishnavi2001', 'Vaishnavi@2001')
    conn.do("USE DATABASE AI_RISK_DB")
    conn.do("USE SCHEMA PUBLIC")
    stmt = conn.run(sql)
    results = []
    while row = stmt.fetch_hash
      results << row.transform_keys(&:downcase).symbolize_keys
    end
    stmt.drop
    conn.disconnect
    results
  end

  def execute(sql, *params)
    conn = ODBC.connect('SnowflakeDSN', 'Vaishnavi2001', 'Vaishnavi@2001')
    conn.do("USE DATABASE AI_RISK_DB")
    conn.do("USE SCHEMA PUBLIC")
    stmt = conn.prepare(sql)
    stmt.execute(*params)
  ensure
    stmt&.drop
    conn&.disconnect
  end

  def insert(table, values)
    keys = values.keys.map(&:to_s)
    placeholders = Array.new(keys.size, '?').join(", ")
    sql = "INSERT INTO #{table} (#{keys.join(', ')}) VALUES (#{placeholders})"
    execute(sql, *values.values)
  end  

  def update(table, id, data)
    set_clause = data.map do |key, value|
      formatted_value = value.is_a?(String) ? "'#{value}'" : value
      "#{key} = #{formatted_value}"
    end.join(', ')
    sql = "UPDATE #{table} SET #{set_clause} WHERE id = #{id};"
    execute(sql)
  end

  def delete(table, id)
    sql = "DELETE FROM #{table} WHERE id = #{id};"
    execute(sql)
  end

  # ✅ Instance-based prediction insert
  def insert_prediction(symbol, predicted_price, risk_level, prediction_time)
    query = <<~SQL
      INSERT INTO AI_RISK_DB.PUBLIC.PREDICTIONS (symbol, predicted_price, risk_level, forecast_date)
      VALUES (?, ?, ?, ?)
    SQL
    execute(query, symbol, predicted_price, risk_level, prediction_time)
  end  
end

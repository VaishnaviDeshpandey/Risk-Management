require 'odbc'

class SnowflakeService
  def self.query(sql)
    conn = ODBC.connect('SnowflakeDSN', 'Vaishnavi2001', 'Vaishnavi@2001')
    results = []

    stmt = conn.run(sql)
    cols = stmt.columns.map { |col| col.is_a?(Array) ? col.first : col }

    while row = stmt.fetch
      row_hash = {}
      cols.each_with_index do |col_name, index|
        row_hash[col_name] = row[index].to_s  # 🔁 force convert to string
      end
      results << row_hash
    end

    stmt.drop
    conn.disconnect

    results
  end
end


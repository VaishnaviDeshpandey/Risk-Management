require 'odbc'

module SnowflakeMigrations
  class Base
    def execute(sql)
      conn = ODBC.connect('SnowflakeDSN', 'Vaishnavi2001', 'Vaishnavi@2001')
      conn.run(sql)
      conn.disconnect
    end
  end
end

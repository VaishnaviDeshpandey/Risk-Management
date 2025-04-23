namespace :snowflake do
    desc "List all tables in the Snowflake PUBLIC schema"
    task list_tables: :environment do
      puts "📋 Listing all tables in AI_RISK_DB.PUBLIC..."
      stmt = SnowflakeClient.connection.run("SHOW TABLES IN SCHEMA ai_risk_db.public;")
      while row = stmt.fetch_hash
        puts "- #{row['name']}"
      end
    end
  
    desc "Describe a specific Snowflake table. Usage: rake snowflake:describe_table TABLE=table_name"
    task describe_table: :environment do
      table = ENV['TABLE']
      if table.blank?
        puts "❌ Please provide a table name. Example: rake snowflake:describe_table TABLE=predictions"
        next
      end
  
      puts "📄 Describing table: #{table}"
      stmt = SnowflakeClient.connection.run("DESC TABLE ai_risk_db.public.#{table};")
      while row = stmt.fetch_hash
        puts "#{row['name']} | #{row['type']} | #{row['null?']} | #{row['default']} | #{row['kind']}"
      end
    end
  
    desc "Preview data in a Snowflake table. Usage: rake snowflake:preview TABLE=table_name"
    task preview: :environment do
      table = ENV['TABLE']
      if table.blank?
        puts "❌ Please provide a table name. Example: rake snowflake:preview TABLE=predictions"
        next
      end
  
      puts "👀 Previewing data from: #{table}"
      stmt = SnowflakeClient.connection.run("SELECT * FROM ai_risk_db.public.#{table} LIMIT 10;")
      rows = stmt.fetch_all
      rows.each_with_index do |row, idx|
        puts "#{idx + 1}. #{row.inspect}"
      end
    end
  end
  
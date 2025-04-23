require 'odbc'

namespace :snowflake do
  desc "Dump ALL Snowflake tables schema to db/snowflake_schema.rb"
  task dump: :environment do
    output_path = Rails.root.join("db/snowflake_schema.rb")
    puts "📄 Dumping all Snowflake tables to: #{output_path}"

    db = ODBC.connect('SnowflakeDSN', 'Vaishnavi2001', 'Vaishnavi@2001')

    tables = []
    db.run("SELECT TABLE_NAME FROM AI_RISK_DB.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'PUBLIC'") do |stmt|
      while row = stmt.fetch_hash
        tables << row["TABLE_NAME"]
      end
    end

    File.open(output_path, "w") do |file|
      file.puts "# Auto-generated Snowflake schema"
      file.puts "# Run with: bundle exec rake snowflake:dump"
      file.puts

      tables.each do |table_name|
        puts "🔍 Found table: #{table_name}"
        file.puts "create_table \"#{table_name.downcase}\", force: :cascade do |t|"

        db.run("SELECT COLUMN_NAME, DATA_TYPE, IS_IDENTITY, NUMERIC_SCALE, NUMERIC_PRECISION
                FROM AI_RISK_DB.INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_NAME = '#{table_name}' AND TABLE_SCHEMA = 'PUBLIC'
                ") do |cols|
          while col = cols.fetch_hash
            rails_type = case col['DATA_TYPE'].downcase
            when /char/, /string/, /text/ then 'string'
            when "number"
              if col['NUMERIC_SCALE'].to_i == 0 && col['NUMERIC_PRECISION'].to_i == 38
                'integer'
              else
                'float'
              end
            when /decimal/, /numeric/, /float/, /real/ then 'float'
            when /boolean/ then 'boolean'
            when /timestamp/, /date/, /datetime/ then 'datetime'
            else 'string'
            end     
            file.puts "  t.#{rails_type} \"#{col['COLUMN_NAME'].downcase}\""
          end
        end

        file.puts "end"
        file.puts
      end
    end
     puts "✅ All schemas dumped successfully!"
  end  # <-- ✅ This was missing

  desc "Run all Snowflake migrations"
  task migrate: :environment do
    puts "🚀 Running Snowflake Migrations..."

    Dir.glob("db/snowflake_migrate/*.rb").sort.each do |file|
      require Rails.root.join(file)

      class_name = File.basename(file, ".rb").split("_").drop(1).map(&:capitalize).join
      klass = Object.const_get(class_name)

      puts "⏳ Running Snowflake migration: #{class_name}"
      klass.new.up
    end

    puts "✅ All Snowflake migrations complete."
  end

  desc "Rollback a specific Snowflake migration"
  task :migrate_down, [:version] => :environment do |t, args|
    if args[:version].nil?
      puts "❌ Please provide a VERSION. Example: rake snowflake:migrate_down[20250407130000]"
      next
    end

    file = Dir.glob("db/snowflake_migrate/#{args[:version]}*.rb").first
    if file.nil?
      puts "❌ Migration file for version #{args[:version]} not found."
      next
    end

    require Rails.root.join(file)
    class_name = File.basename(file, ".rb").split("_").drop(1).map(&:capitalize).join
    klass = Object.const_get(class_name)

    puts "🧨 Rolling back Snowflake migration: #{class_name}"
    klass.new.down
    puts "✅ Migration rolled back."
  end
end  # namespace :snowflake

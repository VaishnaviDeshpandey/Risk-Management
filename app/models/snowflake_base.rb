# app/models/snowflake_base.rb
class SnowflakeBase < ApplicationRecord
  self.abstract_class = true

#   connects_to database: { writing: :snowflake }
end

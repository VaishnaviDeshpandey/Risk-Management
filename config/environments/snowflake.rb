# config/environments/snowflake.rb

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Eager load code on boot. This is necessary in production-like environments.
  config.eager_load = true

  # Set the logger level
  config.log_level = :info

  # Show full error reports only in development or test
  config.consider_all_requests_local = false

  # Use a different cache store in production
  config.cache_store = :memory_store

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n
  config.i18n.fallbacks = true

  # Don't dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Ensure your logs aren't cluttered
  config.assets.quiet = true

  # You can add Snowflake-specific logging or other customizations here
end

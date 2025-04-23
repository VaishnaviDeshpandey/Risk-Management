# Auto-generated Snowflake schema
# Run with: bundle exec rake snowflake:dump

create_table "predictions", force: :cascade do |t|
  t.integer "id"
  t.datetime "forecast_date"
  t.string "symbol"
  t.datetime "updated_at"
  t.datetime "created_at"
  t.string "risk_level"
  t.float "predicted_price"
end

create_table "market_data", force: :cascade do |t|
  t.string "symbol"
  t.integer "id"
  t.float "high"
  t.float "close"
  t.datetime "date"
  t.integer "volume"
  t.float "open"
  t.float "low"
end

create_table "risk_analysis", force: :cascade do |t|
  t.string "prediction"
  t.datetime "updated_at"
  t.datetime "created_at"
  t.float "risk_score"
  t.integer "trade_id"
  t.integer "id"
end

create_table "risk_metrics", force: :cascade do |t|
  t.string "symbol"
  t.integer "id"
  t.float "var_value"
  t.datetime "calculated_at"
  t.float "cvar_value"
end


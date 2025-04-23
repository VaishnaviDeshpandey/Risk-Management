class Api::SnowflakeController < ApplicationController
  def index
    results = SnowflakeService.query("SELECT CURRENT_DATE")
    render json: results
  end
end


class PredictionsController < ApplicationController
  before_action :set_prediction, only: [:show, :edit, :update, :destroy]

  def index
    @predictions = SnowflakeClient.all_predictions
  end

  def show; end

  def new
    @prediction = {}
  end

  def create
    @prediction = SnowflakeClient.create_prediction(prediction_params)
    if @prediction
      redirect_to prediction_path(@prediction[:id]), notice: 'Prediction created.'
    else
      render :new, alert: 'Failed to create prediction.'
    end
  end

  def edit; end

  def update
    @prediction = SnowflakeClient.update_prediction(params[:id], prediction_params)
    redirect_to prediction_path(@prediction[:id]), notice: 'Prediction updated.'
  end

  def destroy
    SnowflakeClient.delete_prediction(params[:id])
    redirect_to predictions_path, notice: 'Prediction deleted.'
  end

  private

  def set_prediction
    @prediction = SnowflakeClient.find_prediction(params[:id])
  end

  def prediction_params
    params.require(:prediction).permit(:symbol, :predicted_price, :risk_level, :forecast_date)
  end
end

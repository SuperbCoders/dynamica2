module API
  module V1
    class PredictedValuesController < API::APIController
      before_action :set_forecast

      # POST /api/v1/forecasts/:forecast_id/predicted_values
      def index
        authorize! :read, @forecast
        @values = @forecast.calculator.series_with_timestamps.map do |key, value| 
          { timestamp: key, value: value, predicted: false }
        end
        @forecast.predicted_values.each do |predicted_value|
          @values << { timestamp: predicted_value.timestamp, value: predicted_value.value, predicted: true }
        end
        @values.sort! do |a, b|
          a[:timestamp] <=> b[:timestamp]
        end
        render json: @values
      end

      private

        def set_forecast
          @forecast = Forecast.find(params[:forecast_id])
        end

    end
  end
end

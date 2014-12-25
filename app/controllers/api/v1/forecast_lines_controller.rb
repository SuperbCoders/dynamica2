module API
  module V1
    class ForecastLinesController < API::APIController
      before_action :set_forecast
      before_action :set_project

      # GET /api/v1/forecasts/:forecast_id/lines
      # GET /api/v1/projects/:project_id/forecasts/:forecast_id/lines
      def index
        authorize! :api_access, @project
        @forecast_lines = @forecast.forecast_lines.includes(:predicted_values, :item).order('items.id ASC')
      end

      private

        def set_forecast
          @forecast = Forecast.find(params[:forecast_id])
        end

        def set_project
          @project = @forecast.project
        end

    end
  end
end

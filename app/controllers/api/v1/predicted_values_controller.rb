module API
  module V1
    class PredictedValuesController < API::APIController
      before_action :set_forecast
      before_action :set_project
      before_action :set_items

      # POST /api/v1/forecasts/:forecast_id/predicted_values
      def index
        authorize! :api_access, @project
        @predictions = @forecast.predicted_values.where(forecast_lines: { item_id: @item_ids }).order(timestamp: :asc).includes(:forecast_line).group_by do |value|
          value.forecast_line.item
        end.map do |item, values|
          Prediction.new(item: item, values: values)
        end
      end

      private

        def set_forecast
          @forecast = Forecast.find(params[:forecast_id])
        end

        def set_project
          @project = @forecast.project
        end

        def set_items
          item_skus = [params[:items]].flatten.select(&:present?)
          @items = @project.items
          @items = @items.where(sku: item_skus) if item_skus.any?
          @item_ids = @items.pluck(:id)
        end

    end
  end
end

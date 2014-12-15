module API
  module V1
    class ForecastsController < API::APIController
      before_action :set_project
      before_action :set_item

      # GET /api/v1/projects/:project_id/items/:item_id/forecasts
      def index
        authorize! :api_access, @project
        @forecasts = @item.forecasts.order(created_at: :asc)
      end

      # POST /api/v1/projects/:project_id/items/:item_id/forecasts
      def create
        authorize! :api_access, @project
        @forecast = @item.forecasts.build(forecast_params)
        if @forecast.save
          render status: :created
        else
          render json: @forecast.errors, status: :unprocessable_entity
        end
      end

      private

        def set_project
          @project = Project.find_by!(slug: params[:project_id])
        end

        def set_item
          @item = @project.items.find_by(sku: params[:item_id])
        end

        def forecast_params
          params.require(:forecast).permit(:period, :depth, :group_method, :from, :to, :planned_at)
        end

    end
  end
end

module API
  module V1
    class ForecastsController < API::APIController
      before_action :set_project

      api :GET, '/v1/projects/:project_id/forecasts', 'List of all the project forecasts'
      description <<-EOS
        It returns a list of all the forecasts creted in the project.

        Successful request responds with 200 status code.
      EOS
      error code: 403, desc: 'Access denied'
      error code: 500, desc: 'Server error'
      example <<-EOS
        // GET /api/v1/projects/my-shop/forecasts

        // Response

        [
          {
            "forecast":{
              "id":85,
              "period":"day",
              "group_method":"sum",
              "depth":5,
              "from":null,
              "to":null,
              "planned_at":"2015-03-06T14:32:14.380Z",
              "started_at":null,
              "finished_at":null,
              "workflow_state":"planned"
            }
          },
          {
            "forecast":{
              "id":86,
              "period":"day",
              "group_method":"sum",
              "depth":5,
              "from":null,
              "to":null,
              "planned_at":"2015-03-06T14:32:14.383Z",
              "started_at":"2015-03-06T14:33:14.093Z",
              "finished_at":"2015-03-06T14:35:14.093Z",
              "workflow_state":"finished"
            }
          }
        ]
      EOS
      def index
        authorize! :api_access, @project
        @forecasts = @project.forecasts.order(created_at: :asc)
        @project.logs.create!(key: 'api.forecasts.index', user: current_user)
        @project.api_used!
      end

      api :POST, '/v1/projects/:project_id/forecasts', 'Create a forecast'
      description <<-EOS
        Create a new forecast. New forecast will be created in "planned" state and will be planned to the closest available time.

        Successful request responds with 201 status code.
        Otherwise see error codes list.

        ## Forecast setup examples

        1. There is an online store. After each order it send to Dynamica data about just sold products (its SKU and sold quantity).
        Assume that we want to predict sales in next 2 month.
        What we need is to group previous purchases by month and sum them.
        So, the following request should be sent:

            `{ "forecast": { "period": "month", "depth": "2", "group_method": "sum" } }`

        2. Every hour we send to Dynamica data about RUB to USD exchange rate.
        We want to predict the exchange for the next 5 days.
        Now there is not sense to calculate sum of all these values. We are interested in the average exchange rate for each day.
        So, the following request should be sent:

            `{ "forecast": { "period": "day", "depth": "5", "group_method": "average" } }`
      EOS
      param :forecast, Hash, desc: 'Description of a new forecast', required: true do
        param :period, ['day', 'month'], desc: 'Time unit of the forecast.', required: true
        param :depth, Integer, desc: 'Depth of the forecast in selected time units. Default: 14 days or 2 month'
        param :group_method, ['sum', 'average'], desc: 'How to group values on. Default: "sum"'
      end
      error code: 422, desc: 'Unprocessable entity'
      error code: 403, desc: 'Access denied'
      error code: 500, desc: 'Server error'
      example <<-EOS
        // POST /api/v1/projects/my-shop/forecasts

        { "forecast": { "period": "month", "depth": "2", "group_method": "sum" } }

        // Response

        {
          "forecast":{
            "id":88,
            "period":"month",
            "depth":2,
            "group_method":"sum",
            "from":null,
            "to":null,
            "workflow_state":"planned",
            "planned_at":"2015-03-06T15:16:58.420Z"
          }
        }
      EOS
      def create
        authorize! :api_access, @project
        @project.api_used!
        @forecast = @project.forecasts.build(forecast_params)
        if @forecast.save
          @project.logs.create!(key: 'api.forecasts.create.success', user: current_user, data: { forecast_id: @forecast.id })
          render status: :created
        else
          @project.logs.create!(key: 'api.forecasts.create.failed', user: current_user)
          render json: @forecast.errors, status: :unprocessable_entity
        end
      end

      private

        def set_project
          @project = Project.find_by!(slug: params[:project_id])
        end

        def forecast_params
          params.require(:forecast).permit(:period, :depth, :group_method, :from, :to, :planned_at)
        end

    end
  end
end

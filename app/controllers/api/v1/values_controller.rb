module API
  module V1
    class ValuesController < API::APIController
      include ItemsManageable

      before_action :set_project

      # POST /api/v1/projects/:project_id/values
      # @required sku [String] SKU of the item.
      #   It could be a new item or the existing one
      # @required value [Float] value that should be stored
      def create
        authorize! :create_value, @project
        authorize! :create, Value
        find_or_create_item
        @value = @item.values.build(value_params)
        if @value.save
          render status: :created
        else
          render json: @value.errors, status: :unprocessable_entity
        end
      end

      private

        def set_project
          @project = Project.find_by!(slug: params[:project_id])
        end

        def value_params
          params.require(:value).permit(:value, :timestamp)
        end

    end
  end
end

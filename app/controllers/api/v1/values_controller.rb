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
        authorize! :api_access, @project
        find_or_create_item
        @values = []
        Value.transaction do
          params[:values].each do |value_params|
            @values << @item.values.build(value_params.permit(:value, :timestamp))
            @values.last.save!
          end
        end
        render status: :created
      rescue ActiveRecord::RecordInvalid
        render json: @values.map(&:errors).reject(&:empty?), status: :unprocessable_entity
      end

      private

        def set_project
          @project = Project.find_by!(slug: params[:project_id])
        end

    end
  end
end

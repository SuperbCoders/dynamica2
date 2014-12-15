module API
  module V1
    class ItemsController < API::APIController
      before_action :set_project
      before_action :set_item

      # DELETE /api/v1/projects/:project_id/items/:item_id/values
      def values
        authorize! :api_access, @project
        @item.values.destroy_all
        head 204
      end

      private

        def set_project
          @project = Project.find_by!(slug: params[:project_id])
        end

        def set_item
          @item = @project.items.find_by!(sku: params[:id])
        end

    end
  end
end

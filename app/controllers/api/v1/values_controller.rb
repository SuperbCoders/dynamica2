module API
  module V1
    class ValuesController < API::APIController
      include ItemsManageable

      before_action :set_project

      api :POST, '/v1/projects/:project_id/values', 'Upload values'
      param :item, Hash, desc: 'Description of a new or the existing item' do
        param :name, String, desc: 'Product name'
        param :sku, String, desc: 'Unique identifier', required: true
      end
      param :values, Array, desc: 'List of values' do
        param :value, [Integer, Float], desc: 'Value', required: true
        param :timestamp, [Date, Time], desc: 'Timestamp', required: true
      end
      error code: 422, desc: 'Unprocessable entity'
      error code: 403, desc: 'Access denied'
      error code: 500, desc: 'Server error'
      example <<-EOS
        // Successful request

        // POST /api/v1/projects/my-shop/values

        {
          {
          "item":{
            "sku":"shampoo",
            "name":"Shampoo for any type of hair"
          },
          "values":[
            {
              "value":1,
              "timestamp":"2015-01-15 10:20:11"
            },
            {
              "value":2,
              "timestamp":"2015-01-16 09:00:17"
            }
          ]
        }

        // Respond

        [
          {
            "value":{
              "value":1.0,
              "timestamp":"2015-01-15T10:20:11.000Z"
            }
          },
          {
            "value":{
              "value":2.0,
              "timestamp":"2015-01-16T09:00:17Z"
            }
          }
        ]
      EOS
      example <<-EOS
        // Request with invalid data

        // POST /api/v1/projects/my-shop/values

        {
          "item":{
            "sku":"shampoo",
            "name":"Shampoo for any type of hair"
          },
          "values":[
            {
              "value":1
            }
          ]
        }

        // Respond

        [
          {
            "timestamp":[
              "can't be blank"
            ]
          }
        ]
      EOS
      description <<-EOS
        It uploads values to the project.

        It accepts item description and array of values.
        If there is no item with the specified SKU it will be created.

        Successfull request responds with 201 status code and returns array of uploaded values.
        Otherwise see error codes list.
      EOS
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

      api :DELETE, '/v1/projects/:project_id/items/:item_id/values', 'Destroy all the values of the selected item'
      api_version 'v1'
      description 'Successfull request destroys all the value of the specified item and respond with 204 status code'
      error code: 403, desc: 'Access denied'
      error code: 500, desc: 'Server error'
      example <<-EOS
        // DELETE /v1/projects/my-shop/items/shampoo/values
        // Responds with empty body and 204 status code
      EOS
      def destroy_all
        authorize! :api_access, @project
        set_item
        @item.values.destroy_all
        head 204
      end

      private

        def set_project
          @project = Project.find_by!(slug: params[:project_id])
        end

        def set_item
          @item = @project.items.find_by!(sku: params[:item_id])
        end

    end
  end
end

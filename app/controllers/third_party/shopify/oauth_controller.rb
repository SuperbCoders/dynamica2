module ThirdParty
  module Shopify
    class OauthController < ApplicationController
      def callback
        shop_name = params[:shop]
        access_token = ShopifyAPI::Session.new(shop_name).request_token(params)

        @project = Project.create(name: shop_name)
        @integration = @project.create_integration(type: 'ShopifyIntegration', code: params[:code], access_token: access_token)

        @project.set_project_owner! current_user, session

        redirect_to project_url(@project)
      end
    end
  end
end

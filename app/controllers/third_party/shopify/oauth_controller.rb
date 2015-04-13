module ThirdParty
  module Shopify
    class OauthController < ApplicationController
      before_action :authenticate_user!

      def callback
        @shop_name = params[:shop]
        session = ShopifyAPI::Session.new(@shop_name)
        token = session.request_token(params)

        @project = current_user.own_projects.create!(name: @shop_name)
        current_user.permissions.create!(project: @project, all: true)
        @shopify_integration = @project.create_shopify_integration!(token: token, shop_name: @shop_name)

        ThirdParty::Shopify::Importer.delay.import(@shopify_integration.id)

        redirect_to project_url(@project)
      end
    end
  end
end

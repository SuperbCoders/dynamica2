module ThirdParty
  module Shopify
    class InstallationController < ApplicationController
      before_action :authenticate_user!
      before_action :set_shop_name

      def index
        session = ShopifyAPI::Session.new(@shop_name)
        scope = ['read_orders']
        permission_url = session.create_permission_url(scope, third_party_shopify_oauth_callback_url)
        redirect_to permission_url
      end

      private

        def set_shop_name
          @shop_name = params[:shop]
        end
    end
  end
end

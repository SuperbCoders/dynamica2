module ThirdParty
  module Shopify
    class OauthController < ApplicationController
      layout 'empty'

      def callback
        redirect_url = nil
        @errors = nil

        @project = Project.where(name: shop_name).first_or_initialize
        if @project.new_record?
          @project.update_attributes(shop_url: params[:shop])

          @user = User.build_temporary_user
          if @user.save

            # Mark user as project owner
            @project.set_project_owner! @user, session

            # Sign in user
            sign_in(@project.user)

            # Create integration
            @integration = @project.create_integration(type: 'ShopifyIntegration', code: params[:code], access_token: access_token)

            redirect_url = "#{dashboard_path}/#/setup"
          else
            @errors ||= @user.errors.full_messages
          end
        elsif @project.user
          sign_in(@project.user)
          redirect_url = dashboard_path
        end

        redirect_to redirect_url if redirect_url && !@errors
      end



      private

      def access_token
        @access_token = ShopifyAPI::Session.new(shop_name).request_token(params)
      end

      def shop_name
        @shop_name = params[:shop] ? params[:shop].split('.myshopify')[0] : nil
      end
    end
  end
end

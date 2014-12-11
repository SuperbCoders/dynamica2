module API
  class APIController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :authenticate
    before_action :set_default_format

    rescue_from CanCan::AccessDenied do |exception|
      render json: 'Access denied', status: 403
    end

    protected

      def authenticate
        authenticate_token || render_unauthorized
      end

      def authenticate_token
        authenticate_with_http_token do |token, options|
          @current_user = User.find_by(api_token: token)
        end
      end

      def render_unauthorized
        self.headers['WWW-Authenticate'] = 'Token realm="Application"'
        render json: 'Bad credentials', status: 401
      end

      def set_default_format
        request.format = :json unless params[:format]
      end
  end
end
class DashboardController < ApplicationController
  # before_action :set_project
  before_action :authenticate_user!

  layout 'dashboard'

  def index
  end

  def profile
    render json: serialize_resource(current_user, UserSerializer)
  end
end

class WelcomeController < ApplicationController
  layout 'landing'

  def index
    redirect_to dashboard_path if current_user
  end

end

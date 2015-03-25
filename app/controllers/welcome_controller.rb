class WelcomeController < ApplicationController
  layout 'landing'
  before_action :redirect_to_projects

  def index
  end

  private

    def redirect_to_projects
      redirect_to projects_url if signed_in?
    end
end

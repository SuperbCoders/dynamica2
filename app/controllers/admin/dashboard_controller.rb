class Admin::DashboardController < Admin::ApplicationController
  # GET /admin
  def index
    @users_count = User.count
    @projects_count = Project.where(demo: false).count
    @forecasts_count = Forecast.joins(:project).where(projects: { demo: false }).count
  end
end

class Admin::ProjectsController < Admin::ApplicationController
  def index
    @projects = Project.select('"projects".*, COUNT("forecasts"."id") AS forecasts_count').joins(:forecasts).group('"projects"."id"')
    @projects = @projects.where(demo: false)
    @projects = @projects.where(demo: false)
    @projects = @projects.includes(:user)
    @projects = @projects.order(created_at: :desc)

    @projects = @projects.where(user_id: params[:user_id]) if params[:user_id].present?

    @projects = @projects.page(params[:page]).per(50)
  end
end

class ForecastsController < ApplicationController
  before_action :set_project

  # GET /projects/:project_id/forecasts
  def index
    authorize! :read, @project
    @forecasts = @project.forecasts.order(planned_at: :desc)
  end

  # GET /projects/:project_id/forecasts/:id
  def show
    authorize! :read, @project
    @forecast = @project.forecasts.find_by!(id: params[:id])
    @forecast_lines = @forecast.forecast_lines.includes(:item)
  end

  private

    def set_project
      @project = Project.friendly.find(params[:project_id])
    end
end

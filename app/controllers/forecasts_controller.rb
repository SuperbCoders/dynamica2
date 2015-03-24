class ForecastsController < ApplicationController
  before_action :set_project

  # GET /projects/:project_id/forecasts/new
  def new
    authorize! :forecasting, @project
    @forecast = @project.forecasts.build
    @recent_forecast = @project.recent_forecast
    @forecast.depth = @recent_forecast.try(:depth) || 10
    @forecast.period = @recent_forecast.try(:period) || 'day'
    @project.items.create! if @project.items.empty?
    @items = @project.items.order(created_at: :desc)
  end

  # POST /projects/:project_id/forecasts
  def create
    authorize! :forecasting, @project
    @forecast = @project.forecasts.build(forecast_params)
    if @forecast.save
      redirect_to project_url(@project)
    else
      @items = @project.items.order(created_at: :desc)
      render :new
    end
  end

  private

    def set_project
      @project = Project.friendly.find(params[:project_id])
    end

    def forecast_params
      params.require(:forecast).permit(:period, :group_method, :depth)
    end
end

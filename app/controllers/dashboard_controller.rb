class DashboardController < ApplicationController
  # before_action :set_project
  before_action :authenticate_user!

  def index
    # params[:from], params[:to] = Time.now.beginning_of_month.to_date, Time.now.to_date
    @project = current_user.projects.first
    # @current_project_characteristics  = @project.project_characteristics.where(date: params[:from]..params[:to])
    # @previous_project_characteristics = @project.project_characteristics.where(date: (params[:from] - (params[:to] - params[:from]))..params[:from])

    # @current_product_characteristics  = @project.product_chracterisitcs.where(date: params[:from]..params[:to])
    # @previous_product_characteristics = @project.product_chracterisitcs.where(date: (params[:from] - (params[:to] - params[:from]))..params[:from])
  end

  private

  def set_project
    @project = Project.friendly.find(params[:id])
  end
end

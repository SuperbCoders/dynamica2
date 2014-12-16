class ItemsController < ApplicationController
  before_action :set_project

  # GET /projects/:project_id/items
  def index
    authorize! :read, @project
    @items = @project.items
  end

  private

    def set_project
      @project = Project.friendly.find(params[:project_id])
    end
end

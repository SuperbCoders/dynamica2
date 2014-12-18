class ItemsController < ApplicationController
  before_action :set_project

  # GET /projects/:project_id/items
  def index
    authorize! :read, @project
    @items = @project.items.order(created_at: :asc)
  end

  # POST /projects/:project_id/items
  def create
    authorize! :forecasting, @project
    @item = @project.items.build(item_params)
    @item.validate_attachment = true
    if @item.save
      render json: { item: @item, html: render_to_string(@item) }, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :forecasting, @project
    @item = @project.items.find_by(id: params[:id])
    if @item.try(:destroy)
      head :no_content
    else
      head :unprocessable_entity
    end
  end

  private

    def set_project
      @project = Project.friendly.find(params[:project_id])
    end

    def item_params
      params.require(:item).permit(:name, :sku, :attachment_id)
    end
end

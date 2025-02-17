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
    if @item.save
      render json: { item: @item, html: render_to_string(@item) }, status: :created
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # PATTCH/PUT /projects/:project_id/items/:id
  def update
    authorize! :forecasting, @project
    @item = @project.items.find(params[:id])
    if @item.update_attributes(item_params)
      render json: { item: @item, html: render_to_string(@item) }, status: :ok
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:project_id/items/:item_id
  def destroy
    authorize! :forecasting, @project
    @item = @project.items.find_by(id: params[:id])
    if @item.try(:destroy)
      head :no_content
    else
      head :unprocessable_entity
    end
  end

  # Destroys all the values from the selected items
  # DELETE /projects/:project_id/items/:id/values
  def values
    authorize! :forecasting, @project
    @item = @project.items.find(params[:id])
    @item.values.destroy_all
    head 204
  end

  private

    def set_project
      @project = Project.friendly.find(params[:project_id])
    end

    def item_params
      if params[:item]
        params.require(:item).permit(:name, :attachment)
      else
        {}
      end
    end
end

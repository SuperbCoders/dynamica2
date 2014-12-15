class PermissionsController < ApplicationController
  before_action :set_permission_and_project, only: [:update, :destroy]

  # GET /projects/:project_id/permissions
  def index
    @project = Project.friendly.find(params[:project_id])
    authorize! :manage, @project
    @permissions = @project.permissions.includes(:user)
  end

  # PATCH/PUT /permissions/:id
  def update
    authorize! :update, @permission
    if @permission.update_attributes(permission_params)
      render json: { permission: @permission, html: render_to_string(partial: 'permissions/permission', object: @permission, as: :permission) }, status: :ok
    else
      render json: @permission.errors, status: :unprocessable_entity
    end
  end

  # DELETE /permissions/:id
  def destroy
    authorize! :destroy, @permission
    @permission.destroy unless @permission.user_id == @project.user_id
    head :no_content
  end

  private

    def permission_params
      params.require(:permission).permit(:manage, :forecasting, :read, :api)
    end

    def set_permission_and_project
      @permission = Permission.find(params[:id])
      @project = @permission.project
      authorize! :manage, @project
    end

end

class PendingPermissionsController < ApplicationController
  before_action :set_project

  # POST /projects/:project_id/pending_permissions
  def create
    @permission = @project.pending_permissions.build(pending_permission_params)
    if @permission.save
      PermissionMailer.invite_user(@permission.email, @permission.token).deliver!
      render json: { permission: @permission, html: render_to_string(partial: 'permissions/pending_permission', object: @permission, as: :permission) }, status: :created
    else
      render json: @permission.errors, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:project_id/pending_permissions/:id
  def destroy
    @permission = PendingPermission.find(params[:id])
    @permission.destroy
    head :no_content
  end

  private

    def set_project
      @project = Project.friendly.find(params[:project_id])
      authorize! :manage, @project
    end

    def pending_permission_params
      params.require(:pending_permission).permit(:email, :manage, :forecasting, :read, :api)
    end
end

class PermissionsController < ApplicationController
  before_action :set_permission_and_project, only: [:update, :destroy]

  before_action :authenticate_user!, only: :activate
  before_action :set_pending_permission, only: :activate
  before_action :check_current_user_email, only: :activate

  # GET /projects/:project_id/permissions
  def index
    @project = Project.friendly.find(params[:project_id])
    authorize! :manage, @project
    @permissions = @project.permissions.includes(:user)
    @pending_permissions = @project.pending_permissions.select(&:persisted?)
    @pending_permission = @project.pending_permissions.build(read: true)
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

  # GET /permissions/:id/activate
  def activate
    @permission = current_user.permissions.create!(project: @pending_permission.project,
                                       manage: @pending_permission.manage?,
                                       forecasting: @pending_permission.forecasting?,
                                       read: @pending_permission.read?,
                                       api: @pending_permission.api?)
    @pending_permission.destroy!
    redirect_to projects_url
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

    def set_pending_permission
      @pending_permission = PendingPermission.find_by(token: params[:id])
    end

    def check_current_user_email
      redirect_to root_url unless @pending_permission.email == current_user.email
    end

end

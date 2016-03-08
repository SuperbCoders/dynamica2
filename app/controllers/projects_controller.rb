class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /projects
  def index
    authorize! :read, Project
    @projects = current_user.projects.includes(:forecasts, :users)
  end

  # GET /projects/:id
  def show
    authorize! :read, @project
    # @forecast = @project.recent_forecast
  end

  # GET /projects/new
  def new
    authorize! :create, Project
    @project = current_user.own_projects.build
  end

  # POST /projects
  def create
    authorize! :create, Project
    @project = current_user.own_projects.build(project_create_params)
    if @project.save
      current_user.permissions.create!(project: @project, all: true)
      redirect_to @project, notice: I18n.t('projects.create.flash.success')
    else
      render :new
    end
  end

  # GET /projects/:id/edit
  def edit
    authorize! :update, @project
  end

  # PATCH/PUT /projects/:id
  def update
    authorize! :update, @project
    if @project.update_attributes(project_update_params)
      redirect_to project_url(@project), notice: I18n.t('projects.update.flash.success')
    else
      render :edit
    end
  end

  # DELETE /projects/:id
  def destroy
    authorize! :destroy, @project
    if @project.destroy
      redirect_to projects_url, notice: I18n.t('project.destroy.flash.success')
    else
      redirect_to projects_url, alert: I18n.t('project.destroy.flash.fail')
    end
  end

  private

    def project_create_params
      params.require(:project).permit(:name)
    end

    def project_update_params
      params.require(:project).permit(:name)
    end

    def set_project
      @project = Project.friendly.find(params[:id])
    end
end

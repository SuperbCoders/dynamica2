class ProjectsController < BaseController
  include Concerns::Resource

  before_action :set_project, only: [:update, :destroy]
  before_action :authorize_user
  before_action :find_resources, only: %w(index)
  before_action :new_resource, only: %w(create new)
  before_action :find_resource, only: %w(show update destroy)

  def search
    @resource = resource_scope.find_by(slug: params[:slug])  if params[:slug]
    send_json serialize_resource(@resource, resource_serializer), @resource.present?
  end

  def create
    @resource.user = current_user
    if @resource.save
      current_user.permissions.create(project: @resource, all: true)
    end
    send_json serialize_resource(@resource, resource_serializer), @resource.valid?
  end

  def resource_scope
    current_user.projects
  end

  def resource_serializer
    ProjectSerializer
  end

  def resource_symbol
    :project
  end

  def search_by
    [:slug]
  end

  def permitted_params
    [ :id,:name, :google_site_id ]
  end

  def authorize_user
    # case action_name.to_sym
    #   when :index
    #     authorize! :read, Project
    #   when :create
    #     authorize! :create, Project
    #   when :show
    #     authorize! :read, @resource
    #   when :update
    #     authorize! :manage, @resource
    #   when :destroy
    #     authorize! :destroy, @resource
    # end
  end

  private


    def set_project
      @resource = Project.friendly.find(params[:id])
    end

  #
  # # GET /projects
  # def index
  #   authorize! :read, Project
  #   @projects = current_user.projects.includes(:forecasts, :users)
  # end
  #
  # def full_chart
  #   authorize! :read, Project
  #   @from, @to, @chart = params[:start_date], params[:finish_date], params[:chart]
  # end
  #
  # # GET /projects/:id
  # def show
  #   authorize! :read, @project
  #   @from, @to = params[:start_date], params[:finish_date]
  #   # @forecast = @project.recent_forecast
  # end
  #
  # # GET /projects/new
  # def new
  #   authorize! :create, Project
  #   @project = current_user.own_projects.build
  # end
  #
  # # POST /projects
  # def create
  #   authorize! :create, Project
  #   @project = current_user.own_projects.build(project_create_params)
  #   if @project.save
  #     current_user.permissions.create!(project: @project, all: true)
  #     redirect_to @project, notice: I18n.t('projects.create.flash.success')
  #   else
  #     render :new
  #   end
  # end
  #
  # # GET /projects/:id/edit
  # def edit
  #   authorize! :update, @project
  # end
  #
  # # PATCH/PUT /projects/:id
  # def update
  #   authorize! :update, @project
  #   if @project.update_attributes(project_update_params)
  #     redirect_to project_url(@project), notice: I18n.t('projects.update.flash.success')
  #   else
  #     render :edit
  #   end
  # end
  #
  # # DELETE /projects/:id
  # def destroy
  #   authorize! :destroy, @project
  #   if @project.destroy
  #     redirect_to projects_url, notice: I18n.t('project.destroy.flash.success')
  #   else
  #     redirect_to projects_url, alert: I18n.t('project.destroy.flash.fail')
  #   end
  # end
  #
  # private
  #
  #   def project_create_params
  #     params.require(:project).permit(:name)
  #   end
  #
  #   def project_update_params
  #     params.require(:project).permit(:name)
  #   end
  #

end

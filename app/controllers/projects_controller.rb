class ProjectsController < ApplicationController

  # GET /projects
  def index
    authorize! :read, Project
  end

end

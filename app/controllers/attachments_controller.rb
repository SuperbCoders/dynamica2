class AttachmentsController < ApplicationController
  before_action :set_project

  # POST /projects/:project_id/attachments
  def create
    authorize! :forecasting, @project
    @attachment = @project.attachments.build(attachment_params)
    if @attachment.save
      render json: @attachment, status: :created
    else
      render json: @attachment.errors, status: :unprocessable_entity
    end
  end

  private

    def set_project
      @project = Project.friendly.find(params[:project_id])
    end

    def attachment_params
      params.require(:attachment).permit(:file)
    end
end

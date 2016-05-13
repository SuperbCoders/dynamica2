class ReportMailer < ActionMailer::Base
  default from: "from@example.com"
  layout 'weekly_report_layout'

  def weekly(project_id, images)
    @project = Project.find(project_id)

    if @project

    end

  end
end

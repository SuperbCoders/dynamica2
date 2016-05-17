class ReportMailer < ActionMailer::Base
  default from: "from@example.com"

  def weekly(params)
    @project = Project.find(params[:project_id])
    @user = @project.user
    @result = params[:result]

    if @project
      mail(to: @user.email, title: "Weekly reporting for #{@project.name}")
    end

  end
end

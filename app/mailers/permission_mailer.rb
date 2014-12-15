class PermissionMailer < ActionMailer::Base
  default from: 'Dynamica <no-reply@dynamica.com>'

  def invite_user(email, token)
    @token = token
    mail(to: email)
  end

end
class UserMailer < ActionMailer::Base
  default from: "report@dynamica.cc"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome.subject
  #
  def welcome(user_id)
    @user = User.find(user_id)

    if @user
      mail to: @user.email, subject: t('devise.registrations.signed_up')
    end

  end
end

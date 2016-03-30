class CustomizedDevise::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  before_filter {
    @omni = request.env["omniauth.auth"]
    @user = user_signed_in? ? current_user : nil

    logger.info "Omni data #{@omni.to_json}" if Rails.env.development?
  }

  def google_oauth2
    provider({google_id: @omni.uid, google_token: @omni.credentials.token})
  end

  def facebook
    provider({fb_id: @omni.uid, fb_token: @omni.credentials.token})
  end

  def provider(omni_fields)
    if user_signed_in?
      create_user_omni(omni_fields)
      @user.update_attributes(user_params) if @user.temporary_user?
    else
      user_omni = UserOmni.find_user(@omni)
      if user_omni
        # Not first sign in
        @user = user_omni.user
      else
        # First sign in
        @user = User.build_from_omni(@omni)
        if @user and not @user.persisted?
          @user.save
          create_user_omni(omni_fields)
        end
      end

    end

    if @user and @user.persisted?
      sign_in(@user)
    end

    redirect_to dashboard_path
  end

  private

  def user_params
    {email: @omni.try(:info).email, name: @omni.try(:info).name}
  end

  def create_user_omni(omni_fields)
    (@user and @user.user_omnis.first_or_create(omni_fields))
  end
end

class CustomizedDevise::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  def edit
    redirect_to root_url(reset_password_token: params[:reset_password_token], anchor: 'password-new')
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      # if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message(:notice, flash_message) if is_flashing_format?
        sign_in(resource_name, resource)
        render json: resource, status: :ok
      # else
      #   set_flash_message(:notice, :updated_not_active) if is_flashing_format?
      #   render json: resource, status: :ok
      # end
    else
      render json: resource.errors.messages, status: :unprocessable_entity
    end
  end
end

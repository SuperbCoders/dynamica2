class CustomizedDevise::PasswordsController < Devise::PasswordsController
  respond_to :json
  clear_respond_to

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?


    render json: resource
  end

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
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      sign_in(resource_name, resource)
      render json: resource, status: :ok
    else
      render json: resource.errors.messages, status: :unprocessable_entity
    end
  end
end

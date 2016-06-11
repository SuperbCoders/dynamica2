class CustomizedDevise::SessionsController < Devise::SessionsController

  respond_to :json

  # GET /resource/sign_in
  def new
    redirect_to root_url(anchor: 'login')
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    render json: { redirect_to: after_sign_in_path_for(resource).to_s }, status: :created
  end
end

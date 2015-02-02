class CustomizedDevise::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  # PATCH/PUT /users/avatar
  def avatar
    if current_user.update_attributes(params.require(:user).permit(:avatar))
      render json: current_user
    else
      render json: current_user.errors.messages, status: :unprocessable_entity
    end
  end

  private

    def configure_permitted_parameters
      allowed_attributes = [:name, :email, :remove_avatar]
      if params[:user] && params[:user][:password].present?
        allowed_attributes << [:password, :password_confirmation, :current_password]
        allowed_attributes.flatten!
      end
      devise_parameter_sanitizer.for(:account_update) do |u|
         u.permit(allowed_attributes)
      end
    end

    def update_resource(resource, params)
      if params[:password].present?
        resource.update_with_password(params)
      else
        resource.update_without_password(params)
      end
    end

    def after_update_path_for(resource)
      edit_user_registration_url
    end

end

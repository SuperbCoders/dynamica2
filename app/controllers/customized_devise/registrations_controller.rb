class CustomizedDevise::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, except: :create

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      Demo.delay.create(resource.id)
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        render json: resource, status: :created
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        render json: resource, status: :created
      end
    else
      clean_up_passwords resource
      # set_minimum_password_length
      render json: resource.errors.messages, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/avatar
  def avatar
    if current_user.update_attributes(params.require(:user).permit(:avatar))
      render json: current_user
    else
      render json: current_user.errors.messages, status: :unprocessable_entity
    end
  end

  protected

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

    def after_sign_up_path_for(resource)
      new_project_url
    end

end

class ProfileController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: serialize_resource(current_user, UserSerializer)
  end

  def update
    logger.info "Profile #{profile_params.to_json}"
    @response[:password] = {}

    if current_user.update_attributes(profile_params)
      @response[:profile] = serialize_resource(current_user, UserSerializer)
    end

    update_password

    render json: @response
  end

  private


  def update_password
    if password_params[:current_password] and password_params[:current_password].length >= 8
      logger.info "Update password with #{password_params}"

      if not current_user.valid_password?
        return @response[:password][:current_password] = true
      end

      if password_params[:password].eql? password_params[:password_confirmation]
        current_user.password = password_params[:password]
        if current_user.save
          sign_in(current_user, bypass: true)
        end
      else
        @response[:password][:new_password] = true
        @response[:password][:password_confirmation] = true
      end
    end
  end
  def password_params
    params.permit(:password, :password_confirmation, :current_password)
  end

  def profile_params
    params.permit(:name, :email)
  end

end

class ProfileController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: serialize_resource(current_user, UserSerializer)
  end

  def update
    logger.info "Profile #{profile_params.to_json}"
    @response[:password] = {}

    if valid_current_password? && current_user.update_attributes(profile_params)
      @response[:profile] = serialize_resource(current_user, UserSerializer)
      @response[:success] = true

      sign_in(current_user, bypass: true)
    end

    render json: @response
  end

  def email_uniqueness
    render json: {exist: email_exists?}
  end

  private

  def valid_current_password?
    if password_params[:current_password]
      if not current_user.valid_password? password_params[:current_password]
        false
      end
    end
    true
  end

  def email_exsists?
    User.where(email: params[:email]).any?
  end

  def password_params
    params.permit(:password, :password_confirmation, :current_password)
  end

  def profile_params
    params.permit(:name, :email, :password)
  end

end

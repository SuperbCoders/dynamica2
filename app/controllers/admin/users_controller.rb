class Admin::UsersController < Admin::ApplicationController
  load_and_authorize_resource param_method: :user_params

  # GET /admin/users
  def index
    @users = @users.where(role: params[:role]) if params[:role].present?
    @users = @users.where('LOWER(name) LIKE ?', "%#{params[:name].mb_chars.downcase.to_s}%") if params[:name].present?
    @users = @users.where('LOWER(email) LIKE ?', "%#{params[:email].mb_chars.downcase.to_s}%") if params[:email].present?
    @users = @users.page(params[:page]).per(50)
  end

  # GET /admin/users/new
  def new
  end

  # POST /admin/users
  def create
    if @user.save
      redirect_to admin_users_url, notice: I18n.t('shared.saved')
    else
      render 'new'
    end
  end

  # GET /admin/users/:id/edit
  def edit
    cookies[:omniauth_redirect_url] = edit_admin_user_url(@user)
  end

  # PUT/PATCH /admin/users/:id
  def update
    account_update_params = user_params
    account_update_params.delete('password') if account_update_params[:password].blank?
    if @user.update_attributes(account_update_params)
      redirect_to admin_users_url, notice: I18n.t('shared.saved')
    else
      render 'edit'
    end
  end

  # DELETE /admin/users/:id
  def destroy
    if @user.id != current_user.id && @user.destroy
      redirect_to admin_users_url, notice: I18n.t('shared.destroyed')
    else
      redirect_to admin_users_url, alert: I18n.t('shared.not_destroyed')
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :name, :role, :avatar, :remove_avatar, :password, :password_confirmation)
    end
end

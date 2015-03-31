class CustomizedDevise::SessionsController < Devise::SessionsController
  def new
    redirect_to root_url(anchor: 'login')
  end
end

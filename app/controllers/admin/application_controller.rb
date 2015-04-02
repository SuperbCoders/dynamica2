class Admin::ApplicationController < ::ApplicationController
  layout 'first_admin_panel/application'
  before_action :authenticate_user!
  before_action { authorize! :access, :admin_panel }
end

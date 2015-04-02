class Admin::ApplicationController < ::ApplicationController
  before_action { authorize! :access_admin_panel }
end

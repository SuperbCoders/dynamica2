class SetDefaultPermissionActions < ActiveRecord::Migration
  class Permission < ActiveRecord::Base
  end

  def up
    Permission.unscoped.each do |permission|
      permission.update_attributes(manage: true, forecasting: true, read: true, api: true)
    end
  end

  def down
  end
end

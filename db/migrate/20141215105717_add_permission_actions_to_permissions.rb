class AddPermissionActionsToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :manage, :boolean, default: false
    add_column :permissions, :forecasting, :boolean, default: false
    add_column :permissions, :read, :boolean, default: false
    add_column :permissions, :api, :boolean, default: false
  end
end

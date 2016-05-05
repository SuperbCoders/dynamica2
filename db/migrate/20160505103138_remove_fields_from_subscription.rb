class RemoveFieldsFromSubscription < ActiveRecord::Migration
  def change
    remove_column :subscriptions, :project_id, :integer
  end
end

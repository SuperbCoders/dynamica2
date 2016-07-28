class AddNotificationsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :news_notification,         :boolean
  	add_column :users, :subscription_notification, :boolean
  end
end

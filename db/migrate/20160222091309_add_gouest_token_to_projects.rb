class AddGouestTokenToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :guest_token, :string
  end
end

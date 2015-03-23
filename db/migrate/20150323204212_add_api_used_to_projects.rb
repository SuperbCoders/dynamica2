class AddAPIUsedToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :api_used, :boolean, default: false
  end
end

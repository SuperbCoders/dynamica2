class AddDemoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :demo, :boolean, default: false
  end
end

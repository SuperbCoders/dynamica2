class AddDataUpdatedAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :data_updated_at, :datetime
  end
end

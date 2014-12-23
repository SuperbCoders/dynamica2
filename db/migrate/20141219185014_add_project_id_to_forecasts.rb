class AddProjectIdToForecasts < ActiveRecord::Migration
  def change
    add_column :forecasts, :project_id, :integer
    add_index :forecasts, :project_id
  end
end

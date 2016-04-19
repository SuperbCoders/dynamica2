class CreateProjectOrderStatuses < ActiveRecord::Migration
  def change
    create_table :project_order_statuses do |t|
      t.string :status
      t.integer :count, default: 0
      t.references :project, index: true
      t.datetime :date

      t.timestamps
    end
  end
end

class CreateForecasts < ActiveRecord::Migration
  def change
    create_table :forecasts do |t|
      t.integer :item_id
      t.boolean :scheduled, default: false
      t.string :period
      t.integer :depth
      t.string :group_method
      t.string :workflow_state
      t.datetime :planned_at
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
    add_index :forecasts, :item_id
  end
end

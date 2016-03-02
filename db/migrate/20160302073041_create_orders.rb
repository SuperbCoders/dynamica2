class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.text :fields, null: false
      t.references :project, index: true, null: false
      t.integer :remote_id, null: false, limit: 8
      t.datetime :remote_updated_at, null: false

      t.timestamps
    end
  end
end

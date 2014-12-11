class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.integer :item_id
      t.float :value
      t.datetime :timestamp

      t.timestamps
    end
    add_index :values, :item_id
  end
end

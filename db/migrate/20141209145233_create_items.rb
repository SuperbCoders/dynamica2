class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.integer :project_id
      t.string :sku
      t.string :name

      t.timestamps
    end
    add_index :items, :project_id
    add_index :items, [:project_id, :sku], unique: true
  end
end

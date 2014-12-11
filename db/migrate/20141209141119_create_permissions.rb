class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end
    add_index :permissions, :user_id
    add_index :permissions, :project_id
    add_index :permissions, [:user_id, :project_id], unique: true
  end
end

class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :key
      t.text :data

      t.timestamps
    end
    add_index :logs, :project_id
    add_index :logs, :user_id
  end
end

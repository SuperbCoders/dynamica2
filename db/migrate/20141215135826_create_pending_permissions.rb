class CreatePendingPermissions < ActiveRecord::Migration
  def change
    create_table :pending_permissions do |t|
      t.string :email
      t.integer :project_id
      t.boolean :manage
      t.boolean :forecasting
      t.boolean :read
      t.boolean :api
      t.string :token

      t.timestamps
    end
    add_index :pending_permissions, :project_id
    add_index :pending_permissions, [:project_id, :email], unique: true
    add_index :pending_permissions, :token, unique: true
  end
end

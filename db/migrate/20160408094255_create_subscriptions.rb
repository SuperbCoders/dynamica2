class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :project, index: true
      t.references :user, index: true
      t.integer :sub_type, default: 0
      t.datetime :expire_at
      t.integer :recurring_id, null: true
      t.integer :one_time_id, null: true
      t.text :last_charge_body, null: true
      t.timestamps
    end
  end
end

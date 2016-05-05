class CreateSubscriptionLogs < ActiveRecord::Migration
  def change
    create_table :subscription_logs do |t|
      t.references :user, index: true
      t.datetime :date
      t.integer :charge_id
      t.text :description
      t.string :amount
      t.string :status

      t.timestamps
    end
  end
end

class CreateSubscriptionPrices < ActiveRecord::Migration
  def change
    create_table :subscription_prices do |t|
    	t.integer :sub_type, default: 0
    	t.float   :cost

      t.timestamps
    end

    add_index :subscription_prices, :sub_type
  end
end

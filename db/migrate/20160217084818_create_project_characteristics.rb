class CreateProjectCharacteristics < ActiveRecord::Migration
  def change
    create_table :project_characteristics do |t|
      t.integer :orders_number, null: false, default: 0
      t.integer :products_number, null: false, default: 0
      t.references :project, index: true, null: false, default: 0
      t.decimal :total_gross_revenues, precision: 10, scale: 2, null: false, default: 0
      t.decimal :total_prices, precision: 10, scale: 2, default: 0
      t.string :currency, null: false, default: 0
      t.integer :customers_number, null: false, default: 0
      t.integer :new_customers_number, null: false, default: 0
      t.integer :repeat_customers_number, null: false, default: 0
      t.float :ratio_of_new_customers_to_repeat_customers, null: false, default: 0
      t.float :average_order_value, null: false, default: 0
      t.float :average_order_size, null: false, default: 0
      t.integer :abandoned_shopping_cart_sessions_number, default: 0
      t.float :average_revenue_per_customer, null: false, default: 0
      t.float :sales_per_visitor, null: false, default: 0
      t.float :average_customer_lifetime_value, null: false, default: 0
      t.float :shipping_cost_as_a_percentage_of_total_revenue, null: false, default: 0
      t.integer :unique_users_number, null: false, default: 0
      t.integer :visits, null: false, default: 0
      t.float :time_on_site, null: false, default: 0
      t.integer :products_in_stock_number, null: false, default: 0
      t.integer :items_in_stock_number, null: false, default: 0
      t.float :percentage_of_inventory_sold, null: false, default: 0
      t.float :percentage_of_stock_sold, null: false, default: 0

      t.timestamps
    end
  end
end

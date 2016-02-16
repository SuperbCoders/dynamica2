class CreateProjectCharacteristics < ActiveRecord::Migration
  def change
    create_table :project_characteristics do |t|
      t.integer :orders_number, null: false
      t.integer :products_number, null: false
      t.references :project, index: true, null: false
      t.decimal :total_gross_revenues, precision: 10, scale: 2, null: false
      t.decimal :total_prices, precision: 10, scale: 2
      t.string :currency, null: false
      t.integer :customers_number, null: false
      t.integer :new_customers_number, null: false
      t.integer :repeat_customers_number, null: false
      t.float :ratio_of_new_customers_to_repeat_customers, null: false
      t.float :average_order_value, null: false
      t.float :average_order_size, null: false
      t.integer :abandoned_shopping_cart_sessions_number
      t.float :average_revenue_per_customer, null: false
      t.float :sales_per_visitor, null: false
      t.float :average_customer_lifetime_value, null: false
      t.float :shipping_cost_as_a_percentage_of_total_revenue, null: false
      t.integer :unique_users_number, null: false
      t.integer :visits, null: false
      t.float :time_on_site, null: false
      t.integer :products_in_stock_number, null: false
      t.integer :items_in_stock_number, null: false
      t.float :percentage_of_inventory_sold, null: false
      t.float :percentage_of_stock_sold, null: false

      t.timestamps
    end
  end
end

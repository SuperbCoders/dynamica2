class ChangeTypeOfRemoteIds < ActiveRecord::Migration
  def up
    change_column :products, :remote_id, :bigint

    remove_index :products, :remote_id
    add_index :products, [:remote_id, :project_id], unique: true
    add_index :products, :remote_id

    change_column_default :project_characteristics, :orders_number, 0
    change_column_default :project_characteristics, :products_number, 0
    change_column_default :project_characteristics, :total_gross_revenues, 0.00
    change_column_default :project_characteristics, :currency, 'USD'
    change_column_default :project_characteristics, :customers_number, 0
    change_column_default :project_characteristics, :new_customers_number, 0
    change_column_default :project_characteristics, :repeat_customers_number, 0
    change_column_default :project_characteristics, :ratio_of_new_customers_to_repeat_customers, 0.0
    change_column_default :project_characteristics, :average_order_value, 0.0
    change_column_default :project_characteristics, :average_order_size, 0.0
    change_column_default :project_characteristics, :average_revenue_per_customer, 0.0
    change_column_default :project_characteristics, :sales_per_visitor, 0.0
    change_column_default :project_characteristics, :average_customer_lifetime_value, 0.0
    change_column_default :project_characteristics, :shipping_cost_as_a_percentage_of_total_revenue, 0.0
    change_column_default :project_characteristics, :unique_users_number, 0
    change_column_default :project_characteristics, :visits, 0
    change_column_default :project_characteristics, :time_on_site, 0.0
    change_column_default :project_characteristics, :products_in_stock_number, 0
    change_column_default :project_characteristics, :items_in_stock_number, 0
    change_column_default :project_characteristics, :percentage_of_inventory_sold, 0.0
    change_column_default :project_characteristics, :percentage_of_stock_sold, 0.0
  end

  def down
    change_column :products, :remote_id, :integer

    remove_index :products, [:remote_id, :project_id]
    remove_index :products, :remote_id
    add_index :products, :remote_id, unique: true

    change_column_default :project_characteristics, :orders_number, nil
    change_column_default :project_characteristics, :products_number, nil
    change_column_default :project_characteristics, :total_gross_revenues, nil
    change_column_default :project_characteristics, :currency, nil
    change_column_default :project_characteristics, :customers_number, nil
    change_column_default :project_characteristics, :new_customers_number, nil
    change_column_default :project_characteristics, :repeat_customers_number, nil
    change_column_default :project_characteristics, :ratio_of_new_customers_to_repeat_customers, nil
    change_column_default :project_characteristics, :average_order_value, nil
    change_column_default :project_characteristics, :average_order_size, nil
    change_column_default :project_characteristics, :average_revenue_per_customer, nil
    change_column_default :project_characteristics, :sales_per_visitor, nil
    change_column_default :project_characteristics, :average_customer_lifetime_value, nil
    change_column_default :project_characteristics, :shipping_cost_as_a_percentage_of_total_revenue, nil
    change_column_default :project_characteristics, :unique_users_number, nil
    change_column_default :project_characteristics, :visits, nil
    change_column_default :project_characteristics, :time_on_site, nil
    change_column_default :project_characteristics, :products_in_stock_number, nil
    change_column_default :project_characteristics, :items_in_stock_number, nil
    change_column_default :project_characteristics, :percentage_of_inventory_sold, nil
    change_column_default :project_characteristics, :percentage_of_stock_sold, nil
  end
end

# == Schema Information
#
# Table name: project_characteristics
#
#  id                                             :integer          not null, primary key
#  orders_number                                  :integer          not null
#  products_number                                :integer          not null
#  project_id                                     :integer          not null
#  total_gross_revenues                           :decimal(10, 2)   not null
#  total_prices                                   :decimal(10, 2)
#  currency                                       :string(255)      not null
#  customers_number                               :integer          not null
#  new_customers_number                           :integer          not null
#  repeat_customers_number                        :integer          not null
#  ratio_of_new_customers_to_repeat_customers     :float            not null
#  average_order_value                            :float            not null
#  average_order_size                             :float            not null
#  abandoned_shopping_cart_sessions_number        :integer
#  average_revenue_per_customer                   :float            not null
#  sales_per_visitor                              :float            not null
#  average_customer_lifetime_value                :float            not null
#  shipping_cost_as_a_percentage_of_total_revenue :float            not null
#  unique_users_number                            :integer          not null
#  visits                                         :integer          not null
#  time_on_site                                   :float            not null
#  products_in_stock_number                       :integer          not null
#  items_in_stock_number                          :integer          not null
#  percentage_of_inventory_sold                   :float            not null
#  percentage_of_stock_sold                       :float            not null
#  created_at                                     :datetime
#  updated_at                                     :datetime
#

FactoryGirl.define do
  factory :project_characteristic do
    orders_number 1
products_number 1
project nil
total_gross_revenues ""
total_gross_revenues ""
total_prices ""
total_prices ""
currency "MyString"
customers_number 1
new_customers_number 1
repeat_customers_number 1
ratio_of_new_customers_to_repeat_customers 1.5
average_order_value 1.5
average_order_size 1.5
abandoned_shopping_cart_sessions_number 1
average_revenue_per_customer 1.5
sales_per_visitor 1.5
average_customer_lifetime_value 1.5
shipping_cost_as_a_percentage_of_total_revenue 1.5
unique_users_number 1
visits 1
time_on_site 1.5
products_in_stock_number 1
items_in_stock_number 1
percentage_of_inventory_sold 1.5
percentage_of_stock_sold 1.5
  end

end

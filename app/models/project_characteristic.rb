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

class ProjectCharacteristic < ActiveRecord::Base
  default_scope -> { order(created_at: :desc) }

  attr_accessor :unique_products_number

  belongs_to :project

  before_save :calculate_statistics

  private

  def calculate_statistics
    ratio_of_new_customers_to_repeat_customers = new_customers_number / repeat_customers_number * 1.0
    average_order_value = total_gross_revenues / orders_number
    average_order_size = products_number / orders_number * 1.0
    average_revenue_per_customer = total_gross_revenues / customers_number
    sales_per_visitor = total_gross_revenues / unique_users_number
    # average_customer_lifetime_value
    # shipping_cost_as_a_percentage_of_total_revenue
    percentage_of_inventory_sold = unique_products_number / products_number * 100.0
    percentage_of_stock_sold = products_number / items_in_stock_number * 100.0
  end
end

# == Schema Information
#
# Table name: project_characteristics
#
#  id                                             :integer          not null, primary key
#  orders_number                                  :integer          default(0), not null
#  products_number                                :integer          default(0), not null
#  project_id                                     :integer          not null
#  total_gross_revenues                           :float            default(0.0), not null
#  total_prices                                   :float
#  currency                                       :string(255)      default("USD"), not null
#  customers_number                               :integer          default(0), not null
#  new_customers_number                           :integer          default(0), not null
#  repeat_customers_number                        :integer          default(0), not null
#  ratio_of_new_customers_to_repeat_customers     :float            default(0.0), not null
#  average_order_value                            :float            default(0.0), not null
#  average_order_size                             :float            default(0.0), not null
#  abandoned_shopping_cart_sessions_number        :integer
#  average_revenue_per_customer                   :float            default(0.0), not null
#  sales_per_visitor                              :float            default(0.0), not null
#  average_customer_lifetime_value                :float            default(0.0), not null
#  shipping_cost_as_a_percentage_of_total_revenue :float            default(0.0), not null
#  unique_users_number                            :integer          default(0), not null
#  visits                                         :integer          default(0), not null
#  time_on_site                                   :float            default(0.0), not null
#  products_in_stock_number                       :integer          default(0), not null
#  items_in_stock_number                          :integer          default(0), not null
#  percentage_of_inventory_sold                   :float            default(0.0), not null
#  percentage_of_stock_sold                       :float            default(0.0), not null
#  created_at                                     :datetime
#  updated_at                                     :datetime
#  date                                           :date             not null
#

require 'rails_helper'

RSpec.describe ProjectCharacteristic, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

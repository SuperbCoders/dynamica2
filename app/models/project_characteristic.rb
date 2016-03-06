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

class ProjectCharacteristic < ActiveRecord::Base
  # default_scope -> { order(created_at: :desc) }

  attr_accessor :unique_products_number

  belongs_to :project

  before_save :replace_bad_values
  before_validation :calculate_statistics

  def total_gross_revenues
    self[:total_gross_revenues].to_f
  end

  def date_week
    self.date.strftime('%W-%Y')
  end

  scope :group_date_by_day, -> { group_by_day(:date, format: "%d-%b-%y", locale: :en) }
  scope :group_date_by_week, -> { group_by_week(:date, week_start: :mon, format: "%W-%Y", locale: :en) }
  scope :group_date_by_month, -> { group_by_month(:date, week_start: :mon, format: "%Y", locale: :en) }

  private

  def replace_bad_values
    ProjectCharacteristic.column_names.each { |p_c_c| val = self.read_attribute(p_c_c); self[p_c_c] = ((val.is_a?(Float) || val.is_a?(BigDecimal)) && val.nan?) ? 0 : val }
  end

  def calculate_statistics
    self.repeat_customers_number = (customers_number - new_customers_number).to_i
    self.ratio_of_new_customers_to_repeat_customers = new_customers_number / repeat_customers_number * 1.0 rescue 0
    self.average_order_value = total_gross_revenues / orders_number rescue 0
    self.average_order_size = products_number / orders_number * 1.0 rescue 0
    self.average_revenue_per_customer = total_gross_revenues / customers_number rescue 0
    self.sales_per_visitor = total_gross_revenues / unique_users_number rescue 0
    # self.average_customer_lifetime_value
    # self.shipping_cost_as_a_percentage_of_total_revenue
    self.percentage_of_inventory_sold = unique_products_number / products_number * 100.0 rescue 0
    self.percentage_of_stock_sold = products_number / items_in_stock_number * 100.0 rescue 0
  end
end

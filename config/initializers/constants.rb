module Dynamica
  # removed charts
  # :average_order_value
  CHART_TYPES = [
      :total_gross_revenues, :products_number, :average_order_size, :customers_number,
      :new_customers_number, :repeat_customers_number, :average_revenue_per_customer, :products_in_stock_number,
      :sales_per_visitor, :average_customer_lifetime_value, :unique_users_number, :visits, :items_in_stock_number,
      :percentage_of_inventory_sold, :percentage_of_stock_sold,
      :shipping_cost_as_a_percentage_of_total_revenue, :orders_number]

  DONUT_CHARTS = [
      :new_and_repeat_customers_number
  ]
  TEMPORARY_MAIL_PREFIX = 'temp.dynamica.cc'

  GENERAL_CHARTS = ['total_gross_revenues','total_gross_delivery', 'shipping_cost_as_a_percentage_of_total_revenue', 'average_order_value', 'average_order_size', 'order_statuses', 'orders_number']
  CUSTOMERS_CHARTS = ['customers_number','new_customers_number','repeat_customers_number','average_revenue_per_customer','sales_per_visitor','average_customer_lifetime_value','unique_users_number','visits', 'new_and_repeat_customers_number']
  PRODUCTS_CHARTS = ['products_in_stock_number','items_in_stock_number','percentage_of_inventory_sold','percentage_of_stock_sold','products_number','products_revenue']

  module Billing
    TRIAL_DAYS = 31
    MONTHLY_PRICE = 5
    YEARLY_PRICE = 4
    YEARLY_PERIOD = 31.days
    MONTHLY_PERIOD = 31.days
    SUBSCRIPTION_TYPES = [:trial, :monthly, :yearly]

  end
end

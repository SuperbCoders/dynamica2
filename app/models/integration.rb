# == Schema Information
#
# Table name: integrations
#
#  id           :integer          not null, primary key
#  project_id   :integer          not null
#  code         :string(255)
#  access_token :string(255)
#  type         :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#

class Integration < ActiveRecord::Base
  validates :project_id, presence: true
  validates :type, presence: true

  belongs_to :project

  ORDER_FIELDS = [
  ].freeze

  CUSTOMER_FIELDS = [
  ].freeze

  PRODUCT_FIELDS = [
  ].freeze

  def fetch(date_from, date_to)
    raise NotImplementedError, 'Subclasses must define `fetch`.'
  end

  after_commit :fetch_data, on: [:create, :update]

  protected

  def get_data
    raise NotImplementedError, 'Subclasses must define `get_data`.'
  end

  def fetch_data
    self.project.fetch_data
  end

  def dump_to_local_database(data)
    dump_products_to_local_database data[:products]
    dump_customers_to_local_database data[:customers]
    dump_orders_to_local_database data[:orders]
  end

  def dump_products_to_local_database(products)
    products.each do |product|
      local_product = Product.find_or_initialize_by remote_id: product.id, project_id: project_id
      next if local_product.remote_updated_at == product.updated_at
      local_product.update_attributes! fields: JSON.parse(product.to_json), remote_updated_at: product.updated_at
    end
  end

  def dump_customers_to_local_database(customers)
    customers.each do |customer|
      local_customer = Customer.find_or_initialize_by remote_id: customer.id, project_id: project_id
      next if local_customer.remote_updated_at == customer.updated_at
      local_customer.update_attributes! fields: JSON.parse(customer.to_json), remote_updated_at: customer.updated_at
    end
  end

  def dump_orders_to_local_database(orders)
    orders.each do |order|
      local_order = Order.find_or_initialize_by remote_id: order.id, project_id: project_id
      next if local_order.remote_updated_at == order.updated_at
      local_order.update_attributes! fields: JSON.parse(order.to_json), remote_updated_at: order.updated_at
    end
  end
end

# == Schema Information
#
# Table name: product_characteristics
#
#  id                 :integer          not null, primary key
#  product_id         :integer          not null
#  price              :decimal(10, 2)   default(0.0), not null
#  inventory_quantity :integer          default(0), not null
#  sold_quantity      :integer          default(0), not null
#  gross_revenue      :decimal(10, 2)   default(0.0), not null
#  created_at         :datetime
#  updated_at         :datetime
#

class ProductCharacteristic < ActiveRecord::Base
  default_scope -> { order(created_at: :desc) }

  belongs_to :product

  before_save :calculate_statistics

  private

  def calculate_statistics
    gross_revenue = price * sold_quantity
  end
end

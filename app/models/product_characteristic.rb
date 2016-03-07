# == Schema Information
#
# Table name: product_characteristics
#
#  id            :integer          not null, primary key
#  product_id    :integer          not null
#  price         :float            default(0.0), not null
#  sold_quantity :integer          default(0), not null
#  gross_revenue :float            default(0.0), not null
#  created_at    :datetime
#  updated_at    :datetime
#  date          :date             not null
#

class ProductCharacteristic < ActiveRecord::Base
  default_scope -> { order(created_at: :desc) }

  belongs_to :product

  before_save :replace_bad_values
  before_validation :calculate_statistics

  private

  def replace_bad_values
    ProductCharacteristic.column_names.each { |p_c_c| val = self.read_attribute(p_c_c); self[p_c_c] = ((val.is_a?(Float) || val.is_a?(BigDecimal)) && val.nan?) ? 0 : val }
  end

  def calculate_statistics
    self.gross_revenue = price * sold_quantity
  end
end

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

FactoryGirl.define do
  factory :product_characteristic do
    product nil
price "9.99"
inventory_quantity 1
sold_quantity 1
gross_revenue "9.99"
  end

end

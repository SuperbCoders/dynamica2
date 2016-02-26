# == Schema Information
#
# Table name: product_characteristics
#
#  id            :integer          not null, primary key
#  product_id    :integer          not null
#  price         :decimal(10, 2)   default(0.0), not null
#  sold_quantity :integer          default(0), not null
#  gross_revenue :decimal(10, 2)   default(0.0), not null
#  created_at    :datetime
#  updated_at    :datetime
#  date          :date             not null
#

require 'rails_helper'

RSpec.describe ProductCharacteristic, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

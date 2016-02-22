# == Schema Information
#
# Table name: third_party_shopify_orders
#
#  id             :integer          not null, primary key
#  integration_id :integer
#  shopify_id     :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class ThirdParty::Shopify::Order < ActiveRecord::Base
  belongs_to :integration, class_name: 'ThirdParty::Shopify::Integration'

  def self.table_name_prefix
    'third_party_shopify_'
  end
end

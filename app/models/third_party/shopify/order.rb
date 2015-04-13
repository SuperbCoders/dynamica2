class ThirdParty::Shopify::Order < ActiveRecord::Base
  belongs_to :integration, class_name: 'ThirdParty::Shopify::Integration'

  def self.table_name_prefix
    'third_party_shopify_'
  end
end

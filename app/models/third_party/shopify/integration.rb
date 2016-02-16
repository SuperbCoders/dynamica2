# == Schema Information
#
# Table name: third_party_shopify_integrations
#
#  id             :integer          not null, primary key
#  project_id     :integer
#  token          :string(255)
#  shop_name      :string(255)
#  last_import_at :datetime
#  fails_count    :integer          default(0)
#  created_at     :datetime
#  updated_at     :datetime
#

class ThirdParty::Shopify::Integration < ActiveRecord::Base
  belongs_to :project
  has_many :orders, class_name: 'ThirdParty::Shopify::Order', dependent: :destroy

  validates :project, presence: true
  validates :token, presence: true
  validates :shop_name, presence: true

  def self.table_name_prefix
    'third_party_shopify_'
  end

  def fail!
    update_attributes(fails_count: fails_count + 1)
  end
end

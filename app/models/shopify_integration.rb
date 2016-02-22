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

class ShopifyIntegration < Integration
  validates :code, presence: true
  validates :access_token, presence: true
end

# == Schema Information
#
# Table name: integrations
#
#  id            :integer          not null, primary key
#  project_id    :integer          not null
#  client_id     :string(255)
#  client_secret :string(255)
#  code          :string(255)
#  access_token  :string(255)
#  type          :string(255)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

class ShopifyIntegration < Integration
end

# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  project_id   :integer
#  sku          :string(255)
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  values_count :integer          default(0)
#  attachment   :string(255)
#

require 'rails_helper'

RSpec.describe Item, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

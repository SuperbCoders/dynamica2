# == Schema Information
#
# Table name: products
#
#  id                 :integer          not null, primary key
#  remote_id          :integer          not null
#  project_id         :integer          not null
#  title              :string(255)      default(""), not null
#  created_at         :datetime
#  updated_at         :datetime
#  inventory_quantity :integer          default(0), not null
#  fields             :text
#  remote_updated_at  :datetime
#

require 'rails_helper'

RSpec.describe Product, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    project
    sequence(:sku) { |i| "ITEM_#{i}" }
    name { sku }
  end
end

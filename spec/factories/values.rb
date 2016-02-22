# == Schema Information
#
# Table name: values
#
#  id         :integer          not null, primary key
#  item_id    :integer
#  value      :float
#  timestamp  :datetime
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :value do
    item
    value 0.0
    timestamp { Time.now }
  end
end

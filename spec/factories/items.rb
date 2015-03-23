# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    project
    sequence(:sku) { |i| "ITEM_#{i}" }
    name { sku }
  end
end

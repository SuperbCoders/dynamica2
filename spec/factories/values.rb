# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :value do
    item
    value 0.0
    timestamp { Time.now }
  end
end

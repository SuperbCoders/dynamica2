FactoryGirl.define do
  factory :predicted_value do
    forecast
    sequence(:timestamp) { |i| (Time.parse('01-01-2014 00:00:00 UTC') + i.days).strftime('%Y-%m-%d') }
    value 1.5
  end
end

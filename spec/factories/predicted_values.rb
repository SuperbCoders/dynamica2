FactoryGirl.define do
  factory :predicted_value do
    forecast
    sequence(:timestamp) { |i| (Time.parse('01-01-2014 00:00:00 UTC') + i.days).strftime('%Y-%m-%d') }
    from { Time.parse(timestamp).beginning_of_day }
    to { Time.parse(timestamp).end_of_day }
    value 1.5
    predicted true
  end
end

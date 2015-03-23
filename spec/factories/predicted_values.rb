FactoryGirl.define do
  factory :predicted_value do
    forecast
    from { Time.now.beginning_of_day }
    to { Time.now.end_of_day }
    value 1.5
    predicted true
  end
end

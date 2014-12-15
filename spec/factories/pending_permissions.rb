FactoryGirl.define do
  factory :pending_permission do
    sequence(:email) { |i| "user-#{i}@example.com" }
    sequence(:token) { |i| i.to_s }
    project
    manage true
    forecasting true
    read true
    api true
  end
end

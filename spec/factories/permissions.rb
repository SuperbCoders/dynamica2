FactoryGirl.define do
  factory :permission do
    user
    project
    manage true
    forecasting true
    read true
    api true
  end
end

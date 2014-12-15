# Read about factories at https://github.com/thoughtbot/factory_girl

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

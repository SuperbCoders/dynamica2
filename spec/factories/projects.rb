# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name 'My Project'
    sequence(:slug) { |i| "project_#{i}" }
  end
end

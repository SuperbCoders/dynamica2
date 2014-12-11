# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@example.com" }
    password 'qwerty123'
    password_confirmation 'qwerty123'

    transient do
      with_projects []
    end

    after(:create) do |user, evaluator|
      evaluator.with_projects.each do |project|
        user.permissions.create!(project: project)
      end
    end
  end
end

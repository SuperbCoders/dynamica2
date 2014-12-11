# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :forecast do
    item
    period 'day'
    depth 5
    group_method 'sum'
    planned_at { 1.minute.since }

    factory :finished_forecast do
      workflow_state 'finished'
      started_at 1.minute.since
      finished_at 3.minutes.since

      after(:create) do |forecast, evaluator|
        forecast.depth.times do |i|
          forecast.predicted_values.create(timestamp: (i+1).days.since.strftime('%Y-%m-%d'), value: (i + 1).to_f)
        end
      end
    end
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :forecast do
    project
    period 'day'
    depth 5
    group_method 'sum'
    planned_at { 1.minute.since }

    transient do
      item nil
    end

    factory :finished_forecast do
      workflow_state 'finished'
      started_at 1.minute.since
      finished_at 3.minutes.since

      after(:create) do |forecast, evaluator|
        forecast_line = forecast.forecast_lines.create!(item: evaluator.item || FactoryGirl.create(:item, project: forecast.project))
        forecast.depth.times do |i|
          time = (i+1).days.since
          timestamp = time.strftime('%Y-%m-%d')
          from = time.beginning_of_day
          to = time.end_of_day
          value = (i + 1).to_f
          forecast_line.predicted_values.create!(timestamp: timestamp, from: from, to: to, value: value, predicted: true)
        end
      end
    end
  end
end

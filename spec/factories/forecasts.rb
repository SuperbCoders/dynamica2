# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :forecast do
    project
    period 'day'
    depth 5
    group_method 'sum'
    planned_at { 1.minute.since }

    factory :finished_forecast do
      workflow_state 'finished'
      started_at 1.minute.since
      finished_at 3.minutes.since

      after(:create) do |forecast, evaluator|
        forecast.project.items.each do |item|
          forecast_line = forecast.forecast_lines.create!(item: item)
          forecast.depth.times do |i|
            time = UTC.parse((i+1).days.since)
            from = time.beginning_of_day
            to = time.end_of_day
            value = (i + 1).to_f
            forecast_line.predicted_values.create!(from: from, to: to, value: value, predicted: true)
          end
        end
        forecast.send(:calculate_summary) if forecast.project.items.count > 1
      end
    end
  end
end

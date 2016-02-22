# == Schema Information
#
# Table name: forecasts
#
#  id             :integer          not null, primary key
#  scheduled      :boolean          default(FALSE)
#  period         :string(255)
#  depth          :integer
#  group_method   :string(255)
#  workflow_state :string(255)
#  planned_at     :datetime
#  started_at     :datetime
#  finished_at    :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  from           :datetime
#  to             :datetime
#  project_id     :integer
#

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

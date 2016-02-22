# == Schema Information
#
# Table name: predicted_values
#
#  id               :integer          not null, primary key
#  forecast_line_id :integer
#  value            :float
#  created_at       :datetime
#  updated_at       :datetime
#  predicted        :boolean          default(FALSE)
#  from             :datetime
#  to               :datetime
#

FactoryGirl.define do
  factory :predicted_value do
    forecast
    from { Time.now.beginning_of_day }
    to { Time.now.end_of_day }
    value 1.5
    predicted true
  end
end

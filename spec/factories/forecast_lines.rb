# == Schema Information
#
# Table name: forecast_lines
#
#  id          :integer          not null, primary key
#  forecast_id :integer
#  item_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  summary     :boolean          default(FALSE)
#

FactoryGirl.define do
  factory :forecast_line do
    forecast
    item
  end

end

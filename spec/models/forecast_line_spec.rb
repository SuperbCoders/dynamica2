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

require 'rails_helper'

RSpec.describe ForecastLine, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

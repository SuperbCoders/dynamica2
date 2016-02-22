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

require 'rails_helper'

RSpec.describe PredictedValue, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

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

require 'rails_helper'

RSpec.describe Forecast, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

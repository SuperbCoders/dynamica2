# == Schema Information
#
# Table name: logs
#
#  id         :integer          not null, primary key
#  project_id :integer
#  user_id    :integer
#  key        :string(255)
#  data       :text
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Log, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

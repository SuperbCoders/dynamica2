# == Schema Information
#
# Table name: values
#
#  id         :integer          not null, primary key
#  item_id    :integer
#  value      :float
#  timestamp  :datetime
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Value, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

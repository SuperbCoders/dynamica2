# == Schema Information
#
# Table name: line_items
#
#  id                :integer          not null, primary key
#  fields            :text             not null
#  project_id        :integer          not null
#  remote_id         :integer          not null
#  remote_updated_at :datetime         not null
#  created_at        :datetime
#  updated_at        :datetime
#

require 'rails_helper'

RSpec.describe LineItem, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

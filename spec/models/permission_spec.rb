# == Schema Information
#
# Table name: permissions
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  project_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  manage      :boolean          default(FALSE)
#  forecasting :boolean          default(FALSE)
#  read        :boolean          default(FALSE)
#  api         :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe Permission, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

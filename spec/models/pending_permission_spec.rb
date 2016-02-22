# == Schema Information
#
# Table name: pending_permissions
#
#  id          :integer          not null, primary key
#  email       :string(255)
#  project_id  :integer
#  manage      :boolean
#  forecasting :boolean
#  read        :boolean
#  api         :boolean
#  token       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe PendingPermission, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

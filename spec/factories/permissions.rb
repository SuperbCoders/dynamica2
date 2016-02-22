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

FactoryGirl.define do
  factory :permission do
    user
    project
    manage true
    forecasting true
    read true
    api true
  end
end

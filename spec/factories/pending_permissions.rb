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

FactoryGirl.define do
  factory :pending_permission do
    sequence(:email) { |i| "user-#{i}@example.com" }
    sequence(:token) { |i| i.to_s }
    project
    manage true
    forecasting true
    read true
    api true
  end
end

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

FactoryGirl.define do
  factory :log do
    project
    user
    key "MyString"
  end
end

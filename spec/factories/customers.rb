# == Schema Information
#
# Table name: customers
#
#  id                :integer          not null, primary key
#  fields            :text             not null
#  project_id        :integer          not null
#  remote_id         :integer          not null
#  remote_updated_at :datetime         not null
#  created_at        :datetime
#  updated_at        :datetime
#

FactoryGirl.define do
  factory :customer do
    
  end

end

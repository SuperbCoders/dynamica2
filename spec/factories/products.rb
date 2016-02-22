# == Schema Information
#
# Table name: products
#
#  id         :integer          not null, primary key
#  remote_id  :integer          not null
#  project_id :integer          not null
#  title      :string(255)      default(""), not null
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :product do
    remote_id 1
project nil
title "MyString"
  end

end

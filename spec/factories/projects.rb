# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  slug        :string(255)
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#  api_used    :boolean          default(FALSE)
#  demo        :boolean          default(FALSE)
#  guest_token :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name { Faker::Name.first_name }
    sequence(:slug) { |i| "project_#{i}" }
  end
end

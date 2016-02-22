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

class Log < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates :project, presence: true
  validates :user, presence: true
  validates :key, presence: true

  serialize :data
end

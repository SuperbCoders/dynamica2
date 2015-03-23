class Log < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates :project, presence: true
  validates :user, presence: true
  validates :key, presence: true

  serialize :data
end

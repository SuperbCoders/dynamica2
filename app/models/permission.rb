class Permission < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  validates :user, presence: true
  validates :project, presence: true, uniqueness: { scope: :user_id }
end

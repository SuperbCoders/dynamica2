class SetDefaultUserIdToProjects < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_many :permissions
    has_many :projects, through: :permissions
  end

  class Permission < ActiveRecord::Base
    belongs_to :user
    belongs_to :project
  end

  class Project < ActiveRecord::Base
    has_many :permissions
    has_many :users, through: :permissions
  end

  def up
    Project.unscoped.includes(:permissions).each do |project|
      user_id = project.permissions.first.try(:user_id)
      project.update_attributes!(user_id: user_id)
    end
  end

  def down
  end
end

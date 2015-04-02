class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)

    if user.persisted?
      can :manage, Project do |project|
        user.permissions.where(manage: true).map(&:project_id).include?(project.id)
      end

      can :forecasting, Project do |project|
        user.permissions.where(forecasting: true).map(&:project_id).include?(project.id)
      end

      can :read, Project do |project|
        user.permissions.where(read: true).map(&:project_id).include?(project.id)
      end

      can :api_access, Project do |project|
        user.permissions.where(api: true).map(&:project_id).include?(project.id)
      end

      can :manage, [Permission, PendingPermission] do |permission|
        user.permissions.where(manage: true).map(&:project_id).include?(permission.project_id)
      end

      if user.role == 'admin'
        can :access, :admin_panel
      end
    end
  end
end

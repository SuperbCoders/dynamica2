class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)

    if user.persisted?
      can :manage, Project do |project|
        user.project_ids.include?(project.id)
      end

      can :api_access, Project do |project|
        user.permissions.where(api: true).map(&:project_id).include?(project.id)
      end

      can :manage, Permission do |permission|
        user.permissions.where(manage: true).map(&:project_id).include?(permission.project_id)
      end
    end
  end
end

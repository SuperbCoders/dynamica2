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

      can :manage, Item do |item|
        user.project_ids.include?(item.project_id)
      end

      can :manage, Value do |value|
        user.project_ids.include?(value.item.project_id)
      end

      can :manage, Forecast do |forecast|
        user.project_ids.include?(forecast.item.project_id)
      end
    end
  end
end

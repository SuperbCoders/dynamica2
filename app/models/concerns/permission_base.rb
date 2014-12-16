# This module describes base behaviour of permissions.
#
# Each class that includes this module should provide the following attributes:
#   * [Integer] project_id
#   * [Boolean] manage
#   * [Boolean] forecasting
#   * [Boolean] read
#   * [Boolean] api
#
# Now there are 2 types of permissions:
#   * Permission - gives access to the project
#   * PendingPermission - gives permission when user follows the invitation link
# 
# Each permission gives one or many of the following actions:
#   * manage (edit and destroy project, invite users to the project team)
#   * forecasting (uploading data, planning forecasts, schedule configuration)
#   * read (read the project overview and calculated forecasts)
#   * api (full API access)
#
# API-permission is independent, but other actions are nested inside each other in the following order:
# read < forecasting < manage
# It means that user with 'forecasting' permission will automatically gets 'read' permission.
#
module PermissionBase
  extend ActiveSupport::Concern

  included do
    # @see #check_all_flag
    attr_accessor :all

    belongs_to :project

    validate :validate_actions

    before_validation :set_nested_actions
    before_validation :check_all_flag
  end

  private

    # Manage permission enables forecasting and read permissions
    # Forecasting permission enables read permission
    # @return [Permission] itself
    def set_nested_actions
      self.forecasting = true if manage?
      self.read = true if forecasting?
      self
    end

    # There is shortcut for creating permission that allows everything:
    #   user.permissions.create(project: @project, all: true)
    # @return [Permission] itself
    def check_all_flag
      if all
        self.manage = true
        self.forecasting = true
        self.read = true
        self.api = true
      end
      self
    end

    # Permission should give at least one action
    def validate_actions
      errors.add(:base, :should_give_at_least_one_action) if !manage? && !forecasting? && !read? && !api?
    end
end

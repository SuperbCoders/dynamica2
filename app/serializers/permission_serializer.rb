class PermissionSerializer < BaseSerializer
  attributes :id, :user_id, :project_id, :created_at, :updated_at, :manage, :forecasting, :read, :api

end

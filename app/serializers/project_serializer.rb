class ProjectSerializer < BaseSerializer
  attributes :id, :name, :slug, :user_id, :api_used, :demo, :guest_token

  has_many :users, serializer: UserSerializer
  has_many :permissions, serializer: PermissionSerializer
end

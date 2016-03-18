class UserSerializer < BaseSerializer
  attributes :email, :id, :name, :avatar, :api_token, :role, :display_name
end

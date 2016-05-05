class UserSerializer < BaseSerializer
  attributes :email, :id, :name, :avatar, :role, :display_name,
      :sign_in_count, :google?, :facebook?

  has_one :subscription, serializer: SubscriptionSerializer
  has_many :subscription_logs

  has_many :projects, serializer: ProjectSerializer
end

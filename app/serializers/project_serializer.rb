class ProjectSerializer < BaseSerializer
  attributes :id, :name, :slug, :user_id, :api_used, :demo, :guest_token,
      :expired, :expire_at, :google_site_id, :shop_url, :sub_type,
      :first_project_data, :first_product_data, :currency

  has_many :users, serializer: UserSerializer
  has_many :permissions, serializer: PermissionSerializer
  has_one :subscription, serializer: SubscriptionSerializer

  def expire_at
    object.try(:subscription).try(:expire_at)
  end

  def expired
    object.try(:expired?)
  end
end

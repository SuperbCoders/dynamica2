class ProjectSerializer < BaseSerializer
  attributes :id, :name, :slug, :user_id, :api_used, :demo, :guest_token,
      :google_site_id, :shop_url, :first_project_data, :first_product_data,
      :currency, :last_update

  has_many :users, serializer: UserSerializer
end

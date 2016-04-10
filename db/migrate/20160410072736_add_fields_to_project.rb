class AddFieldsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :google_site_id, :string
    add_column :projects, :shop_type, :integer
    add_column :projects, :shop_url, :string
  end
end

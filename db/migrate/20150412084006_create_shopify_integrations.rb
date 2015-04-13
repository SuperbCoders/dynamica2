class CreateShopifyIntegrations < ActiveRecord::Migration
  def change
    create_table :third_party_shopify_integrations do |t|
      t.references :project, index: true
      t.string :token
      t.string :shop_name
      t.datetime :last_import_at
      t.integer :fails_count, default: 0

      t.timestamps
    end
  end
end

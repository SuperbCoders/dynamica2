class CreateThirdPartyShopifyOrders < ActiveRecord::Migration
  def change
    create_table :third_party_shopify_orders do |t|
      t.references :integration, index: true
      t.string :shopify_id

      t.timestamps
    end
  end
end

class CreateProductCharacteristics < ActiveRecord::Migration
  def change
    create_table :product_characteristics do |t|
      t.references :product, index: true, null: false
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0.00
      t.integer :inventory_quantity, null: false, default: 0
      t.integer :sold_quantity, null: false, default: 0
      t.decimal :gross_revenue, precision: 10, scale: 2, null: false, default: 0.00

      t.timestamps
    end
  end
end

class MoveInventoryQuantityToProduct < ActiveRecord::Migration
  def up
    add_column :products, :inventory_quantity, :integer, null: false, default: 0
    remove_column :product_characteristics, :inventory_quantity
  end

  def down
    add_column :product_characteristics, :inventory_quantity, :integer, null: false, default: 0
    remove_column :products, :inventory_quantity
  end
end

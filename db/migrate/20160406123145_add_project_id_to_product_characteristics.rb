class AddProjectIdToProductCharacteristics < ActiveRecord::Migration
  def change
    add_reference :product_characteristics, :project, index: true
  end
end

class AddTotalDeliveryCostsToProjectCharacteristic < ActiveRecord::Migration
  def change
    add_column :project_characteristics, :total_gross_delivery, :float, default: 0.0
  end
end

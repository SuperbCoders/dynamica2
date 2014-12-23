class RemoveItemIdFromForecasts < ActiveRecord::Migration
  def change
    remove_index :forecasts, column: :item_id
    remove_column :forecasts, :item_id, :integer
  end
end

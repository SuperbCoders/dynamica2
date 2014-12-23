class CreateForecastLines < ActiveRecord::Migration
  def change
    create_table :forecast_lines do |t|
      t.integer :forecast_id
      t.integer :item_id

      t.timestamps
    end
    add_index :forecast_lines, :forecast_id
    add_index :forecast_lines, :item_id
    add_index :forecast_lines, [:forecast_id, :item_id], unique: true
  end
end

class RemoveTimestampFromPredictedValues < ActiveRecord::Migration
  def change
    remove_column :predicted_values, :timestamp, :string
  end

  def down
    add_column :predicted_values, :timestamp, :string
    add_index :predicted_values, [:forecast_line_id, :timestamp], unique: true
  end
end

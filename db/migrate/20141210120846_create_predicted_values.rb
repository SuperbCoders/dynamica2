class CreatePredictedValues < ActiveRecord::Migration
  def change
    create_table :predicted_values do |t|
      t.integer :forecast_id
      t.string :timestamp
      t.float :value

      t.timestamps
    end
    add_index :predicted_values, :forecast_id
    add_index :predicted_values, [:forecast_id, :timestamp], unique: true
  end
end

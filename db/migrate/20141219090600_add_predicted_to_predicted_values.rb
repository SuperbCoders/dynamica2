class AddPredictedToPredictedValues < ActiveRecord::Migration
  def change
    add_column :predicted_values, :predicted, :boolean, default: false
  end
end

class RenameForecastIdToForecastLineIdInPredictedValues < ActiveRecord::Migration
  def change
    rename_column :predicted_values, :forecast_id, :forecast_line_id
  end
end

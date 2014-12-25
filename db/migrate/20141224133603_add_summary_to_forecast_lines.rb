class AddSummaryToForecastLines < ActiveRecord::Migration
  def change
    add_column :forecast_lines, :summary, :boolean, default: false
  end
end

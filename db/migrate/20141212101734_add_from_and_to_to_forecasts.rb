class AddFromAndToToForecasts < ActiveRecord::Migration
  def change
    add_column :forecasts, :from, :datetime
    add_column :forecasts, :to, :datetime
  end
end

class AddFromAndToToPredictedValues < ActiveRecord::Migration
  def change
    add_column :predicted_values, :from, :datetime
    add_column :predicted_values, :to, :datetime
  end
end

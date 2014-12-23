class DestroyOldForecasts < ActiveRecord::Migration
  def up
    execute("DELETE FROM forecasts")
    execute("DELETE FROM predicted_values")
  end

  def down
  end
end

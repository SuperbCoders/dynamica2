class ChangeBigDeciamToFloat < ActiveRecord::Migration
  def up
    change_column :project_characteristics, :total_gross_revenues, :float
    change_column :project_characteristics, :total_prices, :float

    change_column :product_characteristics, :price, :float
    change_column :product_characteristics, :gross_revenue, :float
  end

  def down
    change_column :project_characteristics, :total_gross_revenues, :decimal, precision: 10, scale: 2
    change_column :project_characteristics, :total_prices, :decimal, precision: 10, scale: 2

    change_column :product_characteristics, :price, :decimal, precision: 10, scale: 2
    change_column :product_characteristics, :gross_revenue, :decimal, precision: 10, scale: 2
  end
end

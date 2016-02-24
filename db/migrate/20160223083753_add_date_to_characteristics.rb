class AddDateToCharacteristics < ActiveRecord::Migration
  def up
    execute "DELETE FROM product_characteristics"
    execute "DELETE FROM project_characteristics"

    add_column :product_characteristics, :date, :date, null: false
    add_column :project_characteristics, :date, :date, null: false
  end

  def down
    remove_column :product_characteristics, :date
    remove_column :project_characteristics, :date
  end
end

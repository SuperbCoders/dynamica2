class AddValuesCountToItems < ActiveRecord::Migration
  def up
    add_column :items, :values_count, :integer, default: 0
    Item.reset_column_information
    Item.all.each do |item|
      Item.update_counters(item.id, values_count: item.values.length)
    end
  end

  def down
    remove_column :items, :values_count
  end
end

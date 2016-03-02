class AddFieldsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :fields, :text
    add_column :products, :remote_updated_at, :datetime
  end
end

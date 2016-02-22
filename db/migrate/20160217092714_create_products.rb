class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :remote_id, null: false
      t.references :project, index: true, null: false
      t.string :title, null: false, default: ''

      t.timestamps
    end

    add_index :products, :remote_id, unique: true
  end
end

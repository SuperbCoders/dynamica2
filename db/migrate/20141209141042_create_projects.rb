class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :slug
      t.string :name

      t.timestamps
    end
    add_index :projects, :slug, unique: true
  end
end

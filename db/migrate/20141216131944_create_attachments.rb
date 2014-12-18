class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :project_id
      t.string :file

      t.timestamps
    end
    add_index :attachments, :project_id
  end
end

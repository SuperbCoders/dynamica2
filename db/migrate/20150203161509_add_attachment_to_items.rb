class AddAttachmentToItems < ActiveRecord::Migration
  def change
    add_column :items, :attachment, :string
  end
end

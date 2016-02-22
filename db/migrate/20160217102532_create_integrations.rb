class CreateIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations do |t|
      t.references :project, index: true, null: false
      t.string :code
      t.string :access_token
      t.string :type, null: false

      t.timestamps
    end
  end
end

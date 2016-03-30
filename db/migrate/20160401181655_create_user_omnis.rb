class CreateUserOmnis < ActiveRecord::Migration
  def change
    create_table :user_omnis do |t|
      t.string :fb_id
      t.string :twitter_id
      t.string :google_id
      t.string :fb_token
      t.string :twitter_token
      t.string :google_token
      t.references :user, index: true

      t.timestamps
    end
  end
end

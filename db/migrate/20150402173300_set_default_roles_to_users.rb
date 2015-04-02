class SetDefaultRolesToUsers < ActiveRecord::Migration
  def up
    execute("UPDATE users SET role='user'")
    ['immaculate.pine@gmail.com', 'osintsev.k.s@gmail.com'].each do |email|
      execute("UPDATE users SET role='admin' WHERE email='#{email}'")
    end
  end

  def down
  end
end

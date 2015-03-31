# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

def create_demo_user
  User.find_by(email: 'demo@dynamica.cc').first_or_create!(password: SecureRandom.hex(32))
end

def create_demo_project_for_sales(user)
  return if user.projects.exist?(name: 'Sales')
  project = user.own_projects.create!(slug: SecureRandom.hex(32), name: 'Sales')
  items = %w(carrot cucumber mango prune)
  items.each do |name|
    item = project.items.create!(sku: name, name: name.capitalize)
  end
end

# demo_user = create_demo_user
# create_demo_project_for_sales(user)
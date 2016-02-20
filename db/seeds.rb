# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

def create_demo_user
  User.where(email: 'demo@dynamica2.cc').first_or_create!(password: '123123Demo')
end

# def create_demo_project_for_sales(user)
#   return if user.own_projects.exists?(name: 'Sales (demo)')
#   project = user.own_projects.create!(slug: SecureRandom.hex(32), name: 'Sales (demo)')
#   user.permissions.create!(project: project, all: true)
#   items = %w(carrot cucumber mango prune)
#   items.each do |name|
#     item = project.items.create!(sku: name, name: name.capitalize)
#     item.attachment = File.open("#{Rails.root}/db/seeds/#{name}.csv")
#     item.save!
#   end
#   forecast = project.forecasts.create!(period: 'month', depth: 3)
#   forecast.start!
# end

# def create_demo_project_for_subscriptions(user)
#   return if user.own_projects.exists?(name: 'Subscriptions (demo)')
#   project = user.own_projects.create!(slug: SecureRandom.hex(32), name: 'Subscriptions (demo)')
#   user.permissions.create!(project: project, all: true)

#   item = project.items.create!(sku: 'subscriptions', name: 'Subscriptions')
#   item.attachment = File.open("#{Rails.root}/db/seeds/subscriptions.csv")
#   item.save!

#   forecast = project.forecasts.create!(period: 'day', depth: 7)
#   forecast.start!
# end

# demo_user = create_demo_user
# create_demo_project_for_sales(demo_user)
# create_demo_project_for_subscriptions(demo_user)

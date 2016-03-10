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

def create_demo_project
  project_name = 'The test project'
  return if Project.where(name: project_name).first

  orders_csv      = CSV.new(File.open("#{Rails.root}/db/seeds/orders.csv").read, headers: true)
  items_csv       = CSV.new(File.open("#{Rails.root}/db/seeds/items.csv").read, headers: true)
  order_items_csv = CSV.new(File.open("#{Rails.root}/db/seeds/order_items.csv").read, headers: true)

  order_items = order_items_csv.to_a.map {|row| row.to_hash}
  items = items_csv.to_a.map {|row| row.to_hash}
  orders = orders_csv.to_a.map {|row| row.to_hash}

  current_project = Project.create name: project_name
  start_date = '06-10-2012'

  previous_orders = []
  previous_order_ids = []
  previous_line_items = []

  (Date.parse(start_date)..Time.now.to_date).each do |date|
    projec_characteristic = ProjectCharacteristic.find_or_initialize_by(date: date, project_id: current_project.id)

    # previous_orders = orders.select {|o| Date.parse(o['created_at']) < date}
    # previous_order_ids = previous_orders.map {|o| o['id']}
    # previous_line_items = order_items.select {|o_i| previous_order_ids.include? o_i['order_id']}

    local_orders = orders.select {|o| Date.parse(o['created_at']) == date}
    order_ids = local_orders.map {|o| o['id']}
    line_items = order_items.select {|o_i| order_ids.include? o_i['order_id']}

    projec_characteristic.update_attributes!(
      orders_number: local_orders.count,
      products_number: line_items.sum {|l_i| l_i['quantity'].to_i},
      total_gross_revenues: line_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f},
      total_prices: 0.0,
      currency: local_orders.first.try(:currency) || 'USD',
      customers_number: local_orders.map {|order| order['user_id']}.compact.uniq.count,
      new_customers_number: local_orders.count { |order| order['user_id'] ? !previous_orders.any? {|p_o| p_o['user_id'] == order['user_id']} : false },
      abandoned_shopping_cart_sessions_number: 0, ####### !!!!!!
      unique_users_number: 0,
      visits: 0, #####
      time_on_site: 0, #####
      products_in_stock_number: 0,
      items_in_stock_number: 0,
      shipping_price: local_orders.sum {|l_o| l_o['shipping_price'].to_f}
    )

    p date if date == date.beginning_of_month

    previous_orders.concat local_orders
    previous_order_ids.concat order_ids
    previous_line_items.concat line_items
  end

  User.all.each {|u| u.permissions.create! project: current_project, manage: true, read: true, forecasting: true, api: true}


  # items.each do |product|
  #   local_product = Product.find_or_initialize_by(remote_id: product['id'], project_id: current_project.id)
  #   local_product.update_attributes!(
  #     title: product['title'],
  #     remote_updated_at: product['updated_at']
  #   )
  # end

  # items.each do |product|
  #   local_product = Product.find_or_initialize_by(remote_id: product['id'], project_id: current_project.id)
  #   local_product.update_attributes!(
  #     title: product['title'],
  #     remote_updated_at: product['updated_at']
  #   )
  # end
end

create_demo_project

require 'csv'

namespace :dynamica do
  namespace :demo do
    desc 'Seed products for project'
    task :seed_products, [:project_id] => :environment do |t, args|
      current_project = Project.find(args.project_id)

      orders = CSV.new(File.open("#{Rails.root}/db/seeds/orders.csv").read, headers: true).to_a.map {|row| row.to_hash}
      items = CSV.new(File.open("#{Rails.root}/db/seeds/items.csv").read, headers: true).to_a.map {|row| row.to_hash}
      order_items = CSV.new(File.open("#{Rails.root}/db/seeds/order_items.csv").read, headers: true).to_a.map {|row| row.to_hash}

      start_date = '01-10-2012'

      previous_orders = []
      previous_order_ids = []
      previous_line_items = []

      Product.where(project: current_project).destroy_all
      ProductCharacteristic.where(project_id: current_project.id).destroy_all

      (Date.parse(start_date)..Time.now.to_date).each do |date|

        local_orders = orders.select {|o| Date.parse(o['created_at']) == date}
        order_ids = local_orders.map {|o| o['id']}
        line_items = order_items.select {|o_i| order_ids.include? o_i['order_id']}

        puts "For #{date.to_datetime} has #{line_items.count} items sold"

        line_items.map { |product|

          item = items.select { |i| i['id'] == product['id']}

          next if item.length < 1

          puts "Sold item #{item.to_json}"
          product['title'] = product['title'] ? product['title'] : item[0]['title']


          local_product = Product.find_or_initialize_by(remote_id: product['id'], project_id: current_project.id)
          local_product.update_attributes!(
              title: product['title'],
              remote_updated_at: product['updated_at']
          )

          puts "Local product #{local_product.to_json}"

          ProductCharacteristic.find_or_initialize_by(date: date, project_id: current_project.id, product_id: local_product.id) do |product_c|
            product_c.price = product['price'].to_i
            product_c.sold_quantity += product['quantity'].to_i
            product_c.gross_revenue = product['quantity'].to_i * product['price'].to_i
            product_c.save
          end

        }

        p date if date == date.beginning_of_month

        previous_orders.concat local_orders
        previous_order_ids.concat order_ids
        previous_line_items.concat line_items
      end

    end

    desc 'Seed demo data to project'
    task :seed, [:project_id] => :environment do |t, args|
      current_project = Project.find(args.project_id)
      current_project = Project.first if not current_project

      order_items = CSV.new(File.open("#{Rails.root}/db/seeds/order_items.csv").read, headers: true).to_a.map {|row| row.to_hash}
      items       = CSV.new(File.open("#{Rails.root}/db/seeds/items.csv").read, headers: true).to_a.map {|row| row.to_hash}
      orders      = CSV.new(File.open("#{Rails.root}/db/seeds/orders.csv").read, headers: true).to_a.map {|row| row.to_hash}

      start_date = '01-10-2012'

      puts "Seed demo data for #{current_project.name}"
      puts "#{orders.length} orders. #{order_items.length} orders items. #{items.length} items."

      previous_orders = []
      previous_order_ids = []
      previous_line_items = []

      Product.where(project: current_project).destroy_all

      items.each do |product|
        local_product = Product.find_or_initialize_by(remote_id: product['id'], project_id: current_project.id)
        local_product.update_attributes!(
            title: product['title'],
            remote_updated_at: product['updated_at']
        )
        puts "Product #{product['name']} created"
      end
      
      ProjectCharacteristic.where(project_id: current_project.id).destroy_all

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
            customers_number: local_orders.map {|order| order['email']}.compact.uniq.count,
            new_customers_number: local_orders.count { |order| order['email'] ? !previous_orders.any? {|p_o| p_o['email'] == order['email']} : false },
            abandoned_shopping_cart_sessions_number: 0, ####### !!!!!!
            unique_users_number: 0,
            visits: 0, #####
            time_on_site: 0, #####
            products_in_stock_number: 0,
            items_in_stock_number: 0,
            shipping_price: local_orders.sum {|l_o| l_o['shipping_price'].to_f}
        )

        p "#{date} : #{local_orders.length} orders. #{line_items.length} items" if date == date.beginning_of_month

        previous_orders.concat local_orders
        previous_order_ids.concat order_ids
        previous_line_items.concat line_items
      end
    end

    desc 'Generates demo CSV file with random data'
    task :csv, [:name, :from, :to, :interval] => :environment do |t, args|
      args.with_defaults(name: 'carrot', from: '01.01.2013', to: Time.now.to_s, interval: 'random')
      from = UTC.parse(args.from)
      to = UTC.parse(args.to)
      interval = case args.interval
      when 'random' then :random
      when 'day' then 1.day
      else args.interval.to_i
      end
      time = from
      CSV.open("#{Rails.root}/db/seeds/#{args.name}.csv", "w") do |csv|
        while time <= to do
          time += interval == :random ? (10.minutes + rand(1.day)) : interval
          csv << [time.strftime('%d.%m.%Y %H:%M:%S'), rand(20) + 1]
        end
      end
    end
  end
end

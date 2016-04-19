module ControllerMacros

  TEST_ORDERS_COUNT_FROM = 2
  TEST_ORDERS_COUNT_TO = 5

  def generate_products_characteristics(project, orders)
    products_statistic = {}
    order_items = []
    items_processed = 0
    not_found_products_ids = []
    not_found_products_count = 0

    orders.each do |order|
      order_date = Date.parse(order['created_at'])
      local_order_items = csv_order_items.select {|o_i| o_i['order_id'] == order['id']}

      order_items += local_order_items

      puts "#{order_date} : Order ##{order['id']} Has #{local_order_items.count} order items. Revenue #{local_order_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f}}"

      # Create Product from CSV
      local_order_items.map {|l_o_item|

        l_o_item['title'] = item_title(l_o_item['item_id'])

        local_product = Product.find_or_initialize_by(remote_id: l_o_item['item_id'], project_id: project.id) do |lp|
          lp.title = l_o_item['title']
          lp.save
        end

        items_processed += 1

        if local_product
          ProductCharacteristic.find_or_initialize_by(date: order_date, project_id: project.id, product_id: local_product.id) do |product_c|
            product_c.price = l_o_item['price'].to_i
            product_c.sold_quantity += l_o_item['quantity'].to_i
            product_c.gross_revenue += l_o_item['quantity'].to_i * l_o_item['price'].to_i
            product_c.save
          end
        else
          not_found_products_count += 1
          not_found_products_ids << l_o_item['id']
          puts "Error! Cant find Product with remote_id #{l_o_item['id']}"
        end
      }

      products_statistic[order_date.strftime("%m.%d.%Y")] ||= []
      products_statistic[order_date.strftime("%m.%d.%Y")] += ProductCharacteristic.where(date: order_date, project_id: project.id)
    end

    # puts "OrderItems #{order_items.to_json}"

    products_statistic
  end

  def generate_test_demo_data(project)
    orders_count = rand(TEST_ORDERS_COUNT_FROM..TEST_ORDERS_COUNT_TO)
    order_items = []
    previous_orders = []
    statistic = {}
    total_statistic = {
        orders_number: 0,
        products_number: 0,
        total_gross_revenues: 0,
        customers_number: 0,
        new_customers_number: 0,
        shipping_price: 0,
        total_gross_delivery: 0,
        average_order_value: 0,
        average_order_size: 0
    }

    # Выбрать из CSV некоторое количество заказов
    csv_orders = CSV.new(File.open("#{Rails.root}/db/seeds/orders.csv").read, headers: true).map { |r| r.to_hash }.to_a[100..100+orders_count]

    puts "Processing #{csv_orders.length} orders"

    # Проходим по всем выбранным из демо данных заказам
    csv_orders.map { |order_data|
      previous_orders << order_data

      # Дата заказа
      date = Date.parse(order_data['created_at'])

      project_characteristic = ProjectCharacteristic.create(date: date, project_id: project.id)



      line_items = csv_order_items.select {|o_i| o_i['order_id'] == order_data['id'] }

      order_items += line_items

      puts "#{date} : Order ##{order_data['id']} with #{line_items.length} order items with $ #{line_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f}}"

      stat = statistic[date.strftime("%m-%d-%y")] ||= {
          orders_number: 0,
          products_number: 0,
          total_gross_revenues: 0,
          customers_number: 0,
          new_customers_number: 0,
          shipping_price: 0,
          total_gross_delivery: 0,
          average_order_value: 0,
          average_order_size: 0
      }

      total_statistic[:orders_number] += 1
      total_statistic[:products_number]  += line_items.sum {|l_i| l_i['quantity'].to_i }
      total_statistic[:total_gross_revenues] += line_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f}
      total_statistic[:customers_number] += 1
      total_statistic[:new_customers_number] += previous_orders.count { |order| order['email'] == order_data['email'] }
      total_statistic[:total_gross_delivery] += (order_data['shipping_price'].to_f || 0)
      total_statistic[:average_order_value] += line_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f}
      total_statistic[:average_order_size] += line_items.sum {|l_i| l_i['quantity'].to_i }

      stat[:orders_number]    += 1
      stat[:products_number]  += line_items.sum {|l_i| l_i['quantity'].to_i }
      stat[:total_gross_revenues] += line_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f}
      stat[:customers_number] += 1
      stat[:new_customers_number] += previous_orders.count { |order| order['email'] == order_data['email'] }
      stat[:total_gross_delivery] += (order_data['shipping_price'].to_f || 0)
      stat[:average_order_value] += line_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f}
      stat[:average_order_size] += line_items.sum {|l_i| l_i['quantity'].to_i }

      project_characteristic.average_order_value = line_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f}
      project_characteristic.average_order_size = line_items.sum {|l_i| l_i['quantity'].to_i }
      project_characteristic.total_gross_delivery = (order_data['shipping_price'].to_f || 0)
      project_characteristic.orders_number = 1
      project_characteristic.products_number = line_items.sum {|l_i| l_i['quantity'].to_i }
      project_characteristic.total_gross_revenues = line_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f}
      project_characteristic.customers_number = 1
      project_characteristic.new_customers_number = previous_orders.count { |order| order['email'] == order_data['email'] }
      project_characteristic.save
    }

    # puts csv_orders.to_json
    puts "Orders #{csv_orders.length} generated"
    puts "Order Items #{order_items.length} generated"
    puts "Total Products sold #{total_statistic[:products_number]}"
    puts "Total gross revenue #{total_statistic[:total_gross_revenues]}"
    puts "Customers #{total_statistic[:customers_number]}"

    total_statistic[:average_order_size] = (total_statistic[:average_order_size].to_f / total_statistic[:orders_number].to_f).round(2)
    total_statistic[:average_order_value] = (total_statistic[:average_order_value].to_f / total_statistic[:orders_number].to_f).round(2)

    return total_statistic, statistic, generate_products_characteristics(project, csv_orders)
  end

  def item_title(item_id)
    csv_items.select { |i| i['id'] == item_id }.first['title']
  end

  def csv_items
    CSV.new(File.open("#{Rails.root}/db/seeds/items.csv").read, headers: true).map { |row| row.to_hash }
  end

  def csv_order_items
    CSV.new(File.open("#{Rails.root}/db/seeds/order_items.csv").read, headers: true).map { |row| row.to_hash }
  end

  def clean_database
    Project.destroy_all
    ProjectCharacteristic.destroy_all
    Product.destroy_all
    ProductCharacteristic.destroy_all
    User.destroy_all
  end

  def login_as(resource)
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = FactoryGirl.create(resource)
      sign_in @user
    end
  end
end

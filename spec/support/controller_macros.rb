module ControllerMacros


  def generate_test_demo_data(project, start_date, end_date)
    items_count = rand(20..40)
    orders_count = rand(100..200)
    items_per_order = rand(1..3)
    items = []
    orders = []
    order_items = []
    previous_orders = []
    previous_order_ids = []
    previous_line_items = []
    products_statistic = {}
    statistic = {}
    total_statistic = {
        orders_number: 0,
        products_number: 0,
        total_gross_revenues: 0,
        customers_number: 0,
        new_customers_number: 0,
        shipping_price: 0
    }

    # Создать заказы, товары и товары в заказах
    csv_items = CSV.new(File.open("#{Rails.root}/db/seeds/items.csv").read, headers: true).to_a[0..items_count]

    csv_items.map {|row|
      product = row.to_hash
      items << product
      local_product = Product.find_or_initialize_by(remote_id: product['id'], project_id: project.id)
      local_product.update_attributes!(title: product['title'],remote_updated_at: product['updated_at'])
    }

    orders_count.times { |i|
      order_params = {
          "id"=>i,
          "state"=>"delivered",
          "name"=>Faker::Name.name,
          "address"=>"yy",
          "city"=>"Москва",
          "zipcode"=>"111111",
          "phone"=>Faker::PhoneNumber.phone_number,
          "email"=>Faker::Internet.safe_email,
          "is_paid"=>"false",
          "total_discount"=>"0",
          "store_id"=>"1",
          "shipping_method_id"=>"3",
          "shipping_price"=>"0",
          "user_id"=>nil,
          "payment_method_id"=>"1",
          "created_at" => (start_date..end_date).to_a.sample.utc
      }

      orders << order_params

      items_per_order.times do |oi|
        order_item = items.sample
        order_items << {
            "id"=>oi,
            "order_id"=>order_params['id'],
            "item_id"=>order_item['id'],
            "price"=>order_item['price'],
            "quantity"=>rand(1..3)
        }
      end
    }

    # 3. Загрузить демо данные в проект
    (start_date..end_date).each do |date|
      projec_characteristic = ProjectCharacteristic.find_or_initialize_by(date: date, project_id: project.id)

      local_orders = orders.select {|o| o['created_at'].to_datetime == date }
      order_ids = local_orders.map {|o| o['id']}
      line_items = order_items.select {|o_i| order_ids.include? o_i['order_id']}

      stat = statistic[date.strftime("%D").gsub('/','-')] ||= {
          orders_number: 0,
          products_number: 0,
          total_gross_revenues: 0,
          customers_number: 0,
          new_customers_number: 0,
          shipping_price: 0
      }

      total_statistic[:orders_number] += local_orders.count
      total_statistic[:products_number]  += line_items.sum {|l_i| l_i['quantity'].to_i }
      total_statistic[:total_gross_revenues] += line_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f}
      total_statistic[:customers_number] += local_orders.map {|order| order['email']}.compact.uniq.count
      total_statistic[:new_customers_number] += local_orders.count { |order| order['email'] ? !previous_orders.any? {|p_o| p_o['email'] == order['email']} : false }
      total_statistic[:shipping_price] += local_orders.sum {|l_o| l_o['shipping_price'].to_f}

      stat[:orders_number]    += local_orders.count
      stat[:products_number]  += line_items.sum {|l_i| l_i['quantity'].to_i }
      stat[:total_gross_revenues] += line_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f}
      stat[:customers_number] += local_orders.map {|order| order['email']}.compact.uniq.count
      stat[:new_customers_number] += local_orders.count { |order| order['email'] ? !previous_orders.any? {|p_o| p_o['email'] == order['email']} : false }
      stat[:shipping_price] += local_orders.sum {|l_o| l_o['shipping_price'].to_f}

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

      line_items.map { |product|

        item = items.select { |i| i['id'] == product['item_id']}[0]

        local_product = Product.find_or_initialize_by(remote_id: item['id'], project_id: project.id)

        ProductCharacteristic.find_or_initialize_by(date: date, project_id: project.id, product_id: local_product.id) do |product_c|
          product_c.price = product['price'].to_i
          product_c.sold_quantity += product['quantity'].to_i
          product_c.gross_revenue += product['quantity'].to_i * product['price'].to_i
          product_c.save
        end


      }

      products_statistic[date.strftime("%m.%d.%Y")] ||= []
      products_statistic[date.strftime("%m.%d.%Y")] += ProductCharacteristic.where(date: date, project_id: project.id)

      previous_orders.concat local_orders
      previous_order_ids.concat order_ids
      previous_line_items.concat line_items
    end

    puts "Orders #{orders.length} generated"
    puts "Order Items #{order_items.length} generated"
    puts "Total Products sold #{total_statistic[:products_number]}"
    puts "Total gross revenue #{total_statistic[:total_gross_revenues]}"
    puts "Customers #{total_statistic[:customers_number]}"
    puts "Product Characteristics #{ProductCharacteristic.where(project_id: project.id).count}"
    return total_statistic, statistic, products_statistic
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

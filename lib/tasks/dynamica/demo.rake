require 'csv'

namespace :dynamica do
  namespace :seed do
    ORDERS_CSV = "#{Rails.root}/db/seeds/orders.csv"
    ORDER_ITEMS_CSV = "#{Rails.root}/db/seeds/order_items.csv"
    ITEMS_CSV = "#{Rails.root}/db/seeds/items.csv"

    desc 'Seed all data for project'
    task :project, [:project_id] => :environment do |t, args|
      project = Project.find(args.project_id)
      if project
        Rake::Task['dynamica:seed:products'].invoke(args.project_id)
        Rake::Task['dynamica:seed:product_characteristics'].invoke(args.project_id)
        Rake::Task['dynamica:seed:orders'].invoke(args.project_id)
        Rake::Task['dynamica:seed:order_statuses'].invoke(args.project_id)
      end

    end

    desc 'Seed products from demo CSV for project by id'
    task :products, [:project_id] => :environment do |t, args|
      # Ищем проект по ID из параметров запуска rake задачи
      project = Project.find(args.project_id)

      # Загружаем заказы, товары в заказах и сами товары
      items = CSV.new(File.open(ITEMS_CSV).read, headers: true).to_a.map {|row| row.to_hash}

      # Очищаем старые данные
      Product.where(project: project).destroy_all

      products_count = 0
      items.map { |product_data|
        # Создаем модель Product для сохранения информации о товаре
        Product.find_or_initialize_by(remote_id: product_data['id'], project_id: project.id) do |product|
          product.update_attributes!(title: product_data['title'], remote_updated_at: product_data['updated_at'])
          if product.valid?
            puts "Product #{product.title} with remote_id #{product.remote_id} created"
            products_count += 1
          else
            puts product.erros.full_messages
          end


        end
      }

      puts "CSV has #{items.length} products"
      puts "Created #{products_count} products for #{project.name}"
    end

    desc 'Seed products for project'
    task :product_characteristics, [:project_id] => :environment do |t, args|
      items_processed = 0
      not_found_products_ids = []
      not_found_products_count = 0

      # Ищем проект по ID из параметров запуска rake задачи
      project = Project.find(args.project_id)

      # Загружаем заказы, товары в заказах и сами товары
      orders = CSV.new(File.open(ORDERS_CSV).read, headers: true).to_a.map {|row| row.to_hash}
      order_items = CSV.new(File.open(ORDER_ITEMS_CSV).read, headers: true).to_a.map {|row| row.to_hash}

      # Очищаем старые данные
      ProductCharacteristic.where(project_id: project.id).destroy_all


      orders.each do |order_data|
        order_date = Date.parse(order_data['created_at'])
        local_order_items = order_items.select {|o_i| o_i['order_id'] == order_data['id']}

        puts "#{order_date} : Has #{local_order_items.count} order items. Revenue #{local_order_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f}}"

        # Создаем или обновляем данные о товаре за этот день
        # - цена
        # - количесво продано
        # - общая выручка от этого товара

        local_order_items.map { |l_o_item|
          items_processed += 1

          # {
          #     "id"=>"107",
          #     "order_id"=>"50",
          #     "item_id"=>"1021",
          #     "price"=>"300",
          #     "quantity"=>"1",
          #     "created_at"=>"2012-12-10 20:13:05 +0400",
          #     "updated_at"=>"2014-10-08 13:31:46 +0400",
          #     "stock_id"=>"1"
          # }
          local_product = Product.find_by(remote_id: l_o_item['item_id'], project_id: project.id)
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
      end

      puts "CSV order items #{order_items.length}. Processed #{items_processed} items from #{orders.length} orders"

    end

    desc 'Seed demo orders from CSV to project'
    task :orders, [:project_id] => :environment do |t, args|
      # Ищем проект из командной строки, либо берем первый в базе
      project = Project.find(args.project_id)

      puts "Seed demo data for #{project.name} at #{DateTime.now.to_s}"

      # Загружаем в переменные данные о
      # order_items - элеметны ( товары ) в заказах
      # items - сами товары ( описание, цена и тд )
      # orders - заказы
      order_items = CSV.new(File.open(ORDER_ITEMS_CSV).read, headers: true).to_a.map {|row| row.to_hash}
      items       = CSV.new(File.open(ITEMS_CSV).read, headers: true).to_a.map {|row| row.to_hash}
      orders      = CSV.new(File.open(ORDERS_CSV).read, headers: true).to_a.map {|row| row.to_hash}

      puts "#{orders.length} orders. #{order_items.length} orders items. #{items.length} items."

      # Очищаем старые данные
      ProjectCharacteristic.where(project_id: project.id).destroy_all

      orders_stat = {}
      orders_count = {}

      # Проходим по каждому заказу из BBS
      orders.each do |order_data|
        orders_stat[order_data['state'].to_sym] ||= 0
        orders_stat[order_data['state'].to_sym] += 1

        # Пропускаем если заказ не delivered
        # next if not ['transit','new','delivered'].include? order_data['state']

        # Дата заказа
        order_created_at = order_data['created_at'][0..9]
        order_date = Date.parse(order_created_at)

        # Берем Order Items с текущим order_id
        local_order_items = order_items.select {|o_i| o_i['order_id'] == order_data['id']}

        # Структура Order Item из BBS
        # {
        #     "id"=>"107",
        #     "order_id"=>"50",
        #     "item_id"=>"1021",
        #     "price"=>"300",
        #     "quantity"=>"1",
        #     "created_at"=>"2012-12-10 20:13:05 +0400",
        #     "updated_at"=>"2014-10-08 13:31:46 +0400",
        #     "stock_id"=>"1"
        # }

        # Создаем ИЛИ находим ProjectCharacteristic с датой заказа.
        # В одном PC может хранится инфа о 10 заказах например.
        ProjectCharacteristic.create(date: order_date, project_id: project.id) do |pc|

          # Суммируем количество заказов
          pc.orders_number += 1

          # Суммируем количество проданных товаров
          pc.products_number += local_order_items.sum {|l_i| l_i['quantity'].to_i }

          # Суммируем доход от заказов за эту дату
          pc.total_gross_revenues += local_order_items.sum {|l_i|
            (l_i['quantity'].to_i * l_i['price'].to_f)
          }

          # + (order_data['shipping_price'].to_f || 0)

          # Общая сумма прайсов ( нахера ?)
          pc.total_prices += local_order_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f}

          # Пока просто +1 кастомер
          pc.customers_number += 1
          # pc.new_customers_number +=
          # и далее нули
          pc.average_order_value = local_order_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f}
          pc.average_order_size = local_order_items.count
          pc.total_gross_delivery = (order_data['shipping_price'].to_f || 0)
          pc.abandoned_shopping_cart_sessions_number = 0
          pc.unique_users_number = 0
          pc.visits = 0
          pc.time_on_site = 0
          pc.products_in_stock_number = 0
          pc.items_in_stock_number = 0
          pc.save
        end
        puts "#{order_date} : Has #{local_order_items.count} order items. Revenue #{local_order_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f}}"
      end


    end

    desc 'Seed order statuses'
    task :order_statuses, [:project_id] => :environment  do |t, args|
      project = Project.find(args.project_id)

      project.project_order_statuses.destroy_all

      orders = CSV.new(File.open(ORDERS_CSV).read, headers: true).to_a.map {|row| row.to_hash}

      orders.map { |order_data|
        os = project.project_order_statuses.find_or_create_by(date: Date.parse(order_data['created_at']), status: order_data['state'])
        os.count += 1
        os.save
        puts "Order #{order_data['id']} has #{order_data['state']}"
      }

      puts "#{project.project_order_statuses.count} OrderStatuses processed for #{project.name}"
    end

  end
end

require 'csv'

namespace :dynamica do
  namespace :seed do
    desc 'Seed products for project'
    task :products, [:project_id] => :environment do |t, args|
      start_date = '01-10-2012'

      # Ищем проект по ID из параметров запуска rake задачи
      current_project = Project.find(args.project_id)

      # Загружаем заказы, товары в заказах и сами товары
      orders = CSV.new(File.open("#{Rails.root}/db/seeds/orders.csv").read, headers: true).to_a.map {|row| row.to_hash}
      items = CSV.new(File.open("#{Rails.root}/db/seeds/items.csv").read, headers: true).to_a.map {|row| row.to_hash}
      order_items = CSV.new(File.open("#{Rails.root}/db/seeds/order_items.csv").read, headers: true).to_a.map {|row| row.to_hash}

      # Очищаем старые данные
      Product.where(project: current_project).destroy_all
      ProductCharacteristic.where(project_id: current_project.id).destroy_all

      (Date.parse(start_date)..Time.now.to_date).each do |date|

        local_orders = orders.select {|o| Date.parse(o['created_at']) == date}
        order_ids = local_orders.map {|o| o['id']}
        line_items = order_items.select {|o_i| order_ids.include? o_i['order_id']}

        puts "#{date} : Has #{local_orders.count} orders with #{line_items.count} selled items. Revenue #{line_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f}}"

        # Проходим по проданным товарам за этот день
        line_items.map { |product|

          # Получаем параметры товара из загруженных CSV
          item = items.select { |i| i['id'] == product['id']}
          next if item.length < 1

          # Получаем название товара
          product['title'] = product['title'] ? product['title'] : item[0]['title']

          # Создаем модель Product для сохранения информации о товаре
          local_product = Product.find_or_initialize_by(remote_id: product['id'], project_id: current_project.id)
          local_product.update_attributes!(title: product['title'],remote_updated_at: product['updated_at'])

          puts "Local product #{local_product.title} - $ #{item[0]['price']}"

          # Создаем или обновляем данные о товаре за этот день
          # - цена
          # - количесво продано
          # - общая выручка от этого товара
          ProductCharacteristic.find_or_initialize_by(date: date, project_id: current_project.id, product_id: local_product.id) do |product_c|
            product_c.price = product['price'].to_i
            product_c.sold_quantity += product['quantity'].to_i
            product_c.gross_revenue = product['quantity'].to_i * product['price'].to_i
            product_c.save
          end

        }
      end
    end

    desc 'Seed demo data to project'
    task :project, [:project_id] => :environment do |t, args|
      # Ищем проект из командной строки, либо берем первый в базе
      current_project = Project.find(args.project_id)
      current_project = Project.first if not current_project

      # Загружаем в переменные данные о
      # order_items - элеметны ( товары ) в заказах
      # items - сами товары ( описание, цена и тд )
      # orders - заказы
      order_items = CSV.new(File.open("#{Rails.root}/db/seeds/order_items.csv").read, headers: true).to_a.map {|row| row.to_hash}
      items       = CSV.new(File.open("#{Rails.root}/db/seeds/items.csv").read, headers: true).to_a.map {|row| row.to_hash}
      orders      = CSV.new(File.open("#{Rails.root}/db/seeds/orders.csv").read, headers: true).to_a.map {|row| row.to_hash}

      # С какой даты начинать импорт.
      start_date = '01-10-2012'

      puts "Seed demo data for #{current_project.name}"
      puts "#{orders.length} orders. #{order_items.length} orders items. #{items.length} items."

      previous_orders = []

      # Очищаем старые данные
      # Product - модель товара
      # ProjectCharacteristic - данные о продажах
      Product.where(project: current_project).destroy_all
      ProjectCharacteristic.where(project_id: current_project.id).destroy_all

      # Циклично проходим по всем товарам из CSV и создаем модель Product
      items.each do |product|

        # Ищем или инцициализируем ( если не найден ) модель Product с ID из CSV ( id BBs )
        local_product = Product.find_or_initialize_by(remote_id: product['id'], project_id: current_project.id)

        # Сохраняем название товара
        local_product.update_attributes!(title: product['title'],remote_updated_at: product['updated_at'])

        puts "Product #{product['title']} created with $ #{product['price']}"
      end

      # Итеративно проходим от даты начала, до текущей даты
      (Date.parse(start_date)..Time.now.to_date).each do |date|
        # Создаем данные о заказах
        project_characteristic = ProjectCharacteristic.find_or_initialize_by(date: date, project_id: current_project.id)

        # Выбираем Order, OrderItem с текущей датой
        local_orders = orders.select {|o| Date.parse(o['created_at']) == date}
        order_ids = local_orders.map {|o| o['id']}
        line_items = order_items.select {|o_i| order_ids.include? o_i['order_id']}

        puts "#{date} : Has #{local_orders.count} orders with #{line_items.count} selled items. Revenue #{line_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f}}"

        # Сохраняем в характристики проекта за эту дату ( в итерации )
        # orders_number - Количество заказов за этот день
        # products_number - КОличество проданных товаров
        # total_gross_revenues - общая выручка
        # total_prices - общая цена
        # currency - валюта
        # customers_number - количество покупателей
        # new_customers_number - количество новых покупателей
        # ....
        project_characteristic.update_attributes!(
            orders_number: local_orders.count,
            products_number: line_items.sum {|l_i| l_i['quantity'].to_i},
            total_gross_revenues: line_items.inject(0) {|acc, l_i| acc + l_i['quantity'].to_i * l_i['price'].to_f},
            total_prices: line_items.sum {|l_i| l_i['quantity'].to_i * l_i['price'].to_f},
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

        # Сохраняем заказы за эти дни в "историю"
        # для поиска новых покупателей
        previous_orders.concat local_orders
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

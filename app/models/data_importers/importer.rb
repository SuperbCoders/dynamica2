module DataImporters
  class Importer
    attr_reader :current_project
    attr_reader :data

    def initialize(current_project, data)
      @current_project, @data = current_project, data

      synchronize_product
    end

    def import!(date)
      orders = data[:orders].select { |order| order.created_at.to_date == date }
      create_project_characteristics orders, date
      create_product_characteristics orders, date
    end

    private

    def create_product_characteristics(orders, date)
      line_items = orders.map(&:line_items).flatten.group_by { |line_item| line_item.product_id } # blank line items
      line_items.each do |product_id, line_items|
        product = Product.where(remote_id: product_id, project_id: current_project.id).first
        next unless product

        product_characteristic = ProductCharacteristic.find_or_initialize_by(date: date, product_id: product.id)
        product_characteristic.update_attributes!(
          price: line_items.first.price,
          sold_quantity: line_items.sum(&:quantity)
        )
      end
    end

    def create_project_characteristics(orders, date)
      projec_characteristic = ProjectCharacteristic.find_or_initialize_by(date: date, project_id: current_project.id)
      projec_characteristic.update_attributes!(
        orders_number: orders.count,
        products_number: orders.inject(0) { |accumulator, order| accumulator + order.line_items.map(&:quantity).reduce(&:+) },
        total_gross_revenues: orders.map(&:total_line_items_price).map(&:to_i).reduce(&:+).to_f,
        total_prices: orders.map(&:total_price).map(&:to_i).reduce(&:+),
        currency: orders.first.try(:currency) || 'USD',
        customers_number: orders.map {|order| order.try(:customer).try(:id)}.compact.uniq.count,
        new_customers_number: orders.map { |order| order.try(:customer) }.compact.uniq.select { |customer| customer.orders_count == 1 }.count,
        abandoned_shopping_cart_sessions_number: 0, ####### !!!!!!
        unique_users_number: 0,
        visits: 0, #####
        time_on_site: 0, #####
        products_in_stock_number: data[:products].map { |product| product.variants.select { |variant| variant.inventory_quantity > 1 }  }.flatten.count,
        items_in_stock_number: data[:products].inject(0) { |accumulator, product| accumulator + product.variants.sum(&:inventory_quantity) },
      )
    end

    def synchronize_product
      data[:products].each do |product|
        local_product = Product.find_or_initialize_by(remote_id: product.id, project_id: current_project.id )
        local_product.update_attributes!(
          title: product.title,
          inventory_quantity: product.variants.sum(&:inventory_quantity)
        )
      end
    end
  end
end

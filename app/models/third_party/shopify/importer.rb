class ThirdParty::Shopify::Importer
  attr_reader :project
  attr_reader :integration

  def initialize(integration)
    @integration = integration
    @project = integration.project
    @items = {}
  end

  # Install the Shopify project.
  # It imports all the data that is found in Shopify account.
  def self.import(integration_id)
    self.new(ThirdParty::Shopify::Integration.find(integration_id)).import
  end

  def import
    ShopifyAPI::Base.activate_session(session)
    orders = get_orders
    integration.update_attributes(last_import_at: Time.now)
    import_orders(orders)
    ShopifyAPI::Base.clear_session
    create_forecast if orders.any?
    orders
  rescue ActiveResource::UnauthorizedAccess, ActiveResource::BadRequest
    integration.fail!
  end

  private

    def session
      @session ||= ShopifyAPI::Session.new(integration.shop_name, integration.token)
    end

    def get_orders
      imported_order_ids = integration.orders.pluck(:shopify_id)
      options = { fulfillment_status: 'shipped', fields: 'id,created_at,line_items' }
      if integration.last_import_at
        options[:created_at_min] = integration.last_import_at.ago(30.days).to_s(:full)
      end
      ShopifyAPI::Order.where(options).reject do |order|
        imported_order_ids.include?(order.id.to_s)
      end
    end

    def import_orders(orders)
      orders.each do |order|
        integration.orders.create!(shopify_id: order.id)
        order.line_items.each do |line_item|
          item = item(line_item.product_id.to_s, line_item.title)
          item.values.create!(timestamp: UTC.parse(order.created_at), value: line_item.quantity)
        end
      end
    end

    def create_forecast
      recent_forecast = project.recent_forecast
      project.forecasts.create!(period: recent_forecast.try(:period) || 'day',
                                depth: recent_forecast.try(:depth) || 10,
                                group_method: recent_forecast.try(:group_method) || 'sum')
    end

    def item(sku, name)
      @items[sku] ||= project.items.where(sku: sku).first_or_create!(name: name)
    end
end

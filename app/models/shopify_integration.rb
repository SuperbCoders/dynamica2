# == Schema Information
#
# Table name: integrations
#
#  id           :integer          not null, primary key
#  project_id   :integer          not null
#  code         :string(255)
#  access_token :string(255)
#  type         :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#

class ShopifyIntegration < Integration
  validates :code, presence: true
  validates :access_token, presence: true

  def fetch(date_from, date_to)
    return nil unless activate!
    @date_from, @date_to = date_from, date_to

    result = get_data

    deactivate!

    result
  end

  private

  def get_data
    if self.project.shopify_session
      @products  = ShopifyAPI::Product.find(:all)
      @customers = ShopifyAPI::Customer.find(:all)
      @orders    = ShopifyAPI::Order.find(:all)

      @result = {
        products: @products,
        customers: @customers,
        orders: @orders
      }

      dump_to_local_database @result
    end
    @result
  end

  def order_params
    {
      params: {
        created_at_min: @date_from,
        created_at_max: @date_to,
        fields: ORDER_FIELDS
      }
    }
  end

  def product_params
    {
      params: {
        fields: PRODUCT_FIELDS
      }
    }
  end

  def customer_params
    {
      params: {
        fields: CUSTOMER_FIELDS
      }
    }
  end

  def activate!
    return false unless session.valid?

    ShopifyAPI::Base.activate_session(session)
  end

  def deactivate!
    ShopifyAPI::Base.clear_session
  end

  def session
    @session ||= ShopifyAPI::Session.new(project.name, access_token)
  end
end

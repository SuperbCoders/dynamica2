class ChartsDataController < ApplicationController
  before_action :set_project
  before_action :authenticate_user!
  before_action :set_chart_data, only: [:big_chart_data, :other_chart_data, :full_chart_data, :sorted_chart_data, :full_chart_check_points]

  include ActionView::Helpers::NumberHelper

  respond_to :json

  def products_characteristics
    set_product_characteristics
    @result = []
    @products = {}
    if @product_characteristics
      @product_characteristics.map { |pc|
        @products[pc.product_id] ||= { sales: 0, gross_revenue: 0, title: '', price: 0 }
        @products[pc.product_id][:product_id] = pc.product_id
        @products[pc.product_id][:price] = pc.price
        @products[pc.product_id][:title] = pc.try(:product).title
        @products[pc.product_id][:sales] += pc.sold_quantity
        @products[pc.product_id][:gross_revenue] += pc.gross_revenue
      }

      @products.keys.map {|k| @result << @products[k] }
    end
    render json: @result
  end

  def big_chart_data
    render json: @project.big_charts_data(period, @current_project_characteristics, @previous_project_characteristics)
  end

  def other_chart_data
    render json: other_charts_data(@current_project_characteristics, @previous_project_characteristics)
  end

  def full_chart_data
    @chart = params[:chart]
    @result = {}

    case params[:chart]
      when 'products_in_stock_number'
        @result[:full] = @project.send(params[:chart], date_from, date_to)
      else
        @result[:full] = @project.send(params[:chart], period, @current_project_characteristics, @previous_project_characteristics)
        @result[:check_points] = full_chart_check_points
    end

    @result[:full][:data] = @result[:full][:data].map {|k, v| {'date' => k, 'close' => v}}
    @result[:table_data] = {}

    chart_type(params[:chart]).map { |chart_type|
      logger.info "Chart is #{chart_type}"
      next if chart_type == 'products_in_stock_number'
      next if chart_type == 'order_statuses'
      next if chart_type == 'products_revenue'
      next if chart_type == 'new_and_repeat_customers_number'
      @result[:table_data][chart_type] = @project.send(chart_type, period, @current_project_characteristics, @previous_project_characteristics)
    }
    render json: @result
  end

  def full_chart_check_points
    result = {}

    # 1 year ago
    current = @project.project_characteristics.where(date: date_from - 12.month..(date_from - 11.month))
    prev = @project.project_characteristics.where(date: date_from - 13.month..(date_from - 12.month))
    result[:year_ago] = @project.send(params[:chart], period, current, prev)

    # 6 month ago
    current = @project.project_characteristics.where(date: date_from - 6.month..(date_from - 5.month))
    prev = @project.project_characteristics.where(date: date_from - 7.month..(date_from - 7.month))
    result[:half_a_year_ago] = @project.send(params[:chart], period,  current, prev)

    # 3 month ago
    current = @project.project_characteristics.where(date: date_from - 3.month..(date_from - 2.month))
    prev = @project.project_characteristics.where(date: date_from - 4.month..(date_from - 2.month))
    result[:three_month_ago] = @project.send(params[:chart], period,  current, prev)


    current = @project.project_characteristics.where(date: date_from - 1.month..(date_from))
    prev = @project.project_characteristics.where(date: date_from - 2.month..(date_from - 1.month))
    result[:month_ago] = @project.send(params[:chart], period,  current, prev)

    result
  end

  def sorted_full_chart_data
    @chart = params[:chart]

    @result = send(params[:chart], period)
    @result[:data] = @result[:data].map {|k, v| {'date' => k, 'close' => v}}.sort_by {|v| params[:date] ? Date.parse(v['date']) : v['close']}
    @result[:data] = @result[:data].reverse if (params[:date] || params[:value]) == 'desc'

    render json: other_charts_data[params[:chart].to_sym]
  end

  private

  def date_from
    @date_from ||= "#{params[:from][3..4]}.#{params[:from][0..1]}.#{params[:from][-4..-1]}".to_datetime
  end

  def date_to
    @date_to ||= "#{params[:to][3..4]}.#{params[:to][0..1]}.#{params[:to][-4..-1]}".to_datetime
  end

  def period
    params[:period] ? "group_date_by_#{params[:period]}" : 'group_date_by_day'
  end

  def set_product_characteristics
    @product_characteristics = @project ? @project.product_characteristics.timeline(date_from, date_to) : nil
  end

  def set_chart_data
    @current_project_characteristics  = @project.project_characteristics.where(date: date_from..date_to)
    @previous_project_characteristics = @project.project_characteristics.where(date: (date_from - (date_to - date_from))...date_from)
  end

  def set_project
    @project = current_user.projects.where(id: params[:project_id]).first
  end

  def other_charts_data(current_data, prev_data)
    scope = period
    result = {
        total_gross_delivery: @project.total_gross_delivery(scope, current_data, prev_data),
        orders_number: @project.orders_number(scope, current_data, prev_data),
        total_gross_revenues: @project.total_gross_revenues(scope, current_data, prev_data),
        products_number: @project.products_number(scope, current_data, prev_data),
        average_order_value: @project.average_order_value(scope, current_data, prev_data),
        average_order_size: @project.average_order_size(scope, current_data, prev_data),
        customers_number: @project.customers_number(scope, current_data, prev_data),
        new_customers_number: @project.new_customers_number(scope, current_data, prev_data),
        repeat_customers_number: @project.repeat_customers_number(scope, current_data, prev_data),
        average_revenue_per_customer: @project.average_revenue_per_customer(scope, current_data, prev_data),
        products_in_stock_number: @project.products_in_stock_number(current_data, prev_data),
        sales_per_visitor: @project.sales_per_visitor(scope, current_data, prev_data),
        average_customer_lifetime_value: @project.average_customer_lifetime_value(scope, current_data, prev_data),
        unique_users_number: @project.unique_users_number(scope, current_data, prev_data),
        visits: @project.visits(scope, current_data, prev_data),
        items_in_stock_number: @project.items_in_stock_number(scope, current_data, prev_data),
        percentage_of_inventory_sold: @project.percentage_of_inventory_sold(scope, current_data, prev_data),
        percentage_of_stock_sold: @project.percentage_of_stock_sold(scope, current_data, prev_data),
        shipping_cost_as_a_percentage_of_total_revenue: @project.shipping_cost_as_a_percentage_of_total_revenue(scope, current_data, prev_data)
    }

    result.each {|k, v|
      result[k][:data] = v[:data].map {|k, v| {'date' => k, 'close' => v}}
    }

    result.merge({
        order_statuses: @project.order_statuses(date_from, date_to),
        new_and_repeat_customers_number: @project.new_and_repeat_customers_number(scope, current_data, prev_data)
    })
  end

  def chart_type(chart_name)
    return Dynamica::GENERAL_CHARTS if Dynamica::GENERAL_CHARTS.include? chart_name
    return Dynamica::CUSTOMERS_CHARTS if Dynamica::CUSTOMERS_CHARTS.include? chart_name
    return Dynamica::PRODUCTS_CHARTS if Dynamica::PRODUCTS_CHARTS.include? chart_name
    []
  end

  def ration
    result = (@current_project_characteristics.sum(:new_customers_number).to_f / @current_project_characteristics.sum(:repeat_customers_number).to_f * 100.0)
    (result.nan? || result.infinite?) ? result : result.round(1)
  end
end

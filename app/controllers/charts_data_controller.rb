class ChartsDataController < ApplicationController
  before_action :set_project
  before_action :authenticate_user!
  before_action :set_chart_data, only: [:big_chart_data, :other_chart_data, :full_chart_data, :sorted_chart_data]

  include ActionView::Helpers::NumberHelper

  respond_to :json

  # First graph - big_chart_data.json?
  # period=day&
  # from=Sat%20Dec%2026%202015%2000:00:00%20GMT+0500%20(AQTT)&
  # to=Sat%20Mar%2026%202016%2000:00:00%20GMT+0500%20(AQTT)&
  # project_id=18
  #
  # Use https://github.com/SuperbCoders/dynamica2/blob/07f85e826b2a541889094703b78e18d4503f9c48/app/assets/javascripts/dashboard.js#L188
  def big_chart_data
    render json: big_charts_data
  end

  # Square blocks after big chart - other_chart_data.json?
  # period=day&
  # from=Sat%20Dec%2026%202015%2000:00:00%20GMT+0500%20(AQTT)&
  # to=Sat%20Mar%2026%202016%2000:00:00%20GMT+0500%20(AQTT)&
  # project_id=18
  #
  # Use https://github.com/SuperbCoders/dynamica2/blob/07f85e826b2a541889094703b78e18d4503f9c48/app/assets/javascripts/dashboard.js#L201
  def other_chart_data
    render json: other_charts_data
  end

  # When other chart clicked
  # Request http://localhost:3000/charts_data/full_chart_data?chart=average_order_size&from=Tue%20Mar%2001%202016%2000:00:00%20GMT+0500%20(AQTT)&to=Sat%20Mar%2026%202016%2000:00:00%20GMT+0500%20(AQTT)&project_id=18&_=1458974488988
  # Use https://github.com/SuperbCoders/dynamica2/blob/07f85e826b2a541889094703b78e18d4503f9c48/app/assets/javascripts/full_chart.js#L238
  def full_chart_data
    @chart = params[:chart]

    @result = send(params[:chart], 'group_date_by_day') 
    @result[:data] = @result[:data].map {|k, v| {'date' => k, 'close' => v}}

    render json: other_charts_data[params[:chart].to_sym]
  end

  # Other chart sort
  # https://github.com/SuperbCoders/dynamica2/blob/07f85e826b2a541889094703b78e18d4503f9c48/app/assets/javascripts/full_chart.js#L137
  def sorted_full_chart_data
    @chart = params[:chart]

    @result = send(params[:chart], 'group_date_by_day')
    @result[:data] = @result[:data].map {|k, v| {'date' => k, 'close' => v}}.sort_by {|v| params[:date] ? Date.parse(v['date']) : v['close']}
    @result[:data] = @result[:data].reverse if (params[:date] || params[:value]) == 'desc'

    render json: other_charts_data[params[:chart].to_sym]
  end

  private

  def set_chart_data
    @current_project_characteristics  = @project.project_characteristics.where(date: date_from..date_to)
    @previous_project_characteristics = @project.project_characteristics.where(date: (date_from - (date_to - date_from))...date_from)
  end

  def date_from
    @date_from ||= Date.parse params[:from]
  end

  def date_to
    @date_to ||= Date.parse params[:to]
  end

  def period
    params[:period] ? params[:period] : 'day'
  end

  def set_project
    @project = current_user.projects.where(id: params[:project_id]).first
  end

  def diff_values(current_value, previous_value)
    result = (current_value * 100.0 / previous_value - 100)
    result = (result.nan? || result.infinite?) ? 0 : result.round
    return '' if result.zero?
    result > 0 ? "+#{result}%" : "#{result}%"
  end

  def average_sum(relation, field)
    (relation.sum(field) / relation.count).round 1
  end

  def diff_sum(field)
    diff_values @current_project_characteristics.sum(field), @previous_project_characteristics.sum(field)
  end

  def diff_average_sum(field)
    diff_values(average_sum(@current_project_characteristics, field), average_sum(@previous_project_characteristics, field))
  end

  def total_revenu(scope)
    {
        diff: diff_sum(:total_gross_revenues),
        value: "#{@current_project_characteristics.sum :total_gross_revenues}$",
        data: @current_project_characteristics.send(scope).sum(:total_gross_revenues)
    }
  end

  def products_number(scope)
    {
        diff: diff_sum(:products_number),
        value: "#{@current_project_characteristics.sum :products_number}",
        data: @current_project_characteristics.send(scope).sum(:products_number)
    }
  end

  def average_order_value(scope)
    {
        diff: diff_average_sum(:average_order_value),
        value: "#{average_sum @current_project_characteristics, :average_order_value}",
        data: @current_project_characteristics.send(scope).sum(:average_order_value)
    }
  end

  def average_order_size(scope)
    {
        diff: diff_average_sum(:average_order_size),
        value: "#{average_sum @current_project_characteristics, :average_order_size}",
        data: @current_project_characteristics.send(scope).sum(:average_order_size)
    }
  end

  def customers_number(scope)
    {
        diff: diff_sum(:customers_number),
        value: "#{@current_project_characteristics.sum :customers_number}",
        data: @current_project_characteristics.send(scope).sum(:customers_number)
    }
  end

  def new_customers_number(scope)
    {
        diff: diff_sum(:new_customers_number),
        value: "#{@current_project_characteristics.sum :new_customers_number}",
        data: @current_project_characteristics.send(scope).sum(:new_customers_number)
    }
  end

  def repeat_customers_number(scope)
    {
        diff: diff_sum(:repeat_customers_number),
        value: "#{@current_project_characteristics.sum :repeat_customers_number}",
        data: @current_project_characteristics.send(scope).sum(:repeat_customers_number)
    }
  end

  def average_revenue_per_customer(scope)
    {
        diff: diff_average_sum(:average_revenue_per_customer),
        value: "#{average_sum(@current_project_characteristics, :average_revenue_per_customer)}",
        data: @current_project_characteristics.send(scope).sum(:average_revenue_per_customer)
    }
  end

  def products_in_stock_number(scope)
    {
        diff: diff_sum(:products_in_stock_number),
        value: "#{@current_project_characteristics.sum :products_in_stock_number}",
        data: @current_project_characteristics.send(scope).sum(:products_in_stock_number)
    }
  end

  def sales_per_visitor(scope)
    {
        diff: diff_sum(:sales_per_visitor),
        value: "#{@current_project_characteristics.sum :sales_per_visitor}",
        data: @current_project_characteristics.send(scope).sum(:sales_per_visitor)
    }
  end

  def average_customer_lifetime_value(scope)
    {
        diff: diff_sum(:average_customer_lifetime_value),
        value: "#{@current_project_characteristics.sum :average_customer_lifetime_value}",
        data: @current_project_characteristics.send(scope).sum(:average_customer_lifetime_value)
    }
  end

  def unique_users_number(scope)
    {
        diff: diff_sum(:unique_users_number),
        value: "#{@current_project_characteristics.sum :unique_users_number}",
        data: @current_project_characteristics.send(scope).sum(:unique_users_number)
    }
  end

  def visits(scope)
    {
        diff: diff_sum(:visits),
        value: "#{@current_project_characteristics.sum :visits}",
        data: @current_project_characteristics.send(scope).sum(:visits)
    }
  end

  def items_in_stock_number(scope)
    {
        diff: diff_sum(:items_in_stock_number),
        value: "#{@current_project_characteristics.sum :items_in_stock_number}",
        data: @current_project_characteristics.send(scope).sum(:items_in_stock_number)
    }
  end

  def percentage_of_inventory_sold(scope)
    {
        diff: diff_average_sum(:percentage_of_inventory_sold),
        value: "#{average_sum(@current_project_characteristics, :percentage_of_inventory_sold)}",
        data: @current_project_characteristics.send(scope).sum(:percentage_of_inventory_sold)
    }
  end

  def percentage_of_stock_sold(scope)
    {
        diff: diff_average_sum(:percentage_of_stock_sold),
        value: "#{average_sum(@current_project_characteristics, :percentage_of_stock_sold)}",
        data: @current_project_characteristics.send(scope).sum(:percentage_of_stock_sold)
    }
  end

  def shipping_cost_as_a_percentage_of_total_revenue(scope)
    {
        diff: diff_average_sum(:shipping_cost_as_a_percentage_of_total_revenue),
        value: "#{average_sum @current_project_characteristics, :shipping_cost_as_a_percentage_of_total_revenue}",
        data: @current_project_characteristics.send(scope).sum(:shipping_cost_as_a_percentage_of_total_revenue)
    }
  end

  def other_charts_data
    scope = "group_date_by_day"
    result = {
        total_revenu: {
            diff: diff_sum(:total_gross_revenues),
            value: "#{@current_project_characteristics.sum :total_gross_revenues}$",
            data: @current_project_characteristics.send(scope).sum(:total_gross_revenues)
        },
        products_number: {
            diff: diff_sum(:products_number),
            value: "#{@current_project_characteristics.sum :products_number}",
            data: @current_project_characteristics.send(scope).sum(:products_number)
        },
        average_order_value: {
            diff: diff_average_sum(:average_order_value),
            value: "#{average_sum @current_project_characteristics, :average_order_value}",
            data: @current_project_characteristics.send(scope).sum(:average_order_value)
        },
        average_order_size: {
            diff: diff_average_sum(:average_order_size),
            value: "#{average_sum @current_project_characteristics, :average_order_size}",
            data: @current_project_characteristics.send(scope).sum(:average_order_size)
        },
        customers_number: {
            diff: diff_sum(:customers_number),
            value: "#{@current_project_characteristics.sum :customers_number}",
            data: @current_project_characteristics.send(scope).sum(:customers_number)
        },
        new_customers_number: {
            diff: diff_sum(:new_customers_number),
            value: "#{@current_project_characteristics.sum :new_customers_number}",
            data: @current_project_characteristics.send(scope).sum(:new_customers_number)
        },
        repeat_customers_number: {
            diff: diff_sum(:repeat_customers_number),
            value: "#{@current_project_characteristics.sum :repeat_customers_number}",
            data: @current_project_characteristics.send(scope).sum(:repeat_customers_number)
        },
        average_revenue_per_customer: {
            diff: diff_average_sum(:average_revenue_per_customer),
            value: "#{average_sum(@current_project_characteristics, :average_revenue_per_customer)}",
            data: @current_project_characteristics.send(scope).sum(:average_revenue_per_customer)
        },
        products_in_stock_number: {
            diff: diff_sum(:products_in_stock_number),
            value: "#{@current_project_characteristics.sum :products_in_stock_number}",
            data: @current_project_characteristics.send(scope).sum(:products_in_stock_number)
        },
        sales_per_visitor: {
            diff: diff_sum(:sales_per_visitor),
            value: "#{@current_project_characteristics.sum :sales_per_visitor}",
            data: @current_project_characteristics.send(scope).sum(:sales_per_visitor)
        },
        average_customer_lifetime_value: {
            diff: diff_sum(:average_customer_lifetime_value),
            value: "#{@current_project_characteristics.sum :average_customer_lifetime_value}",
            data: @current_project_characteristics.send(scope).sum(:average_customer_lifetime_value)
        },
        unique_users_number: {
            diff: diff_sum(:unique_users_number),
            value: "#{@current_project_characteristics.sum :unique_users_number}",
            data: @current_project_characteristics.send(scope).sum(:unique_users_number)
        },
        visits: {
            diff: diff_sum(:visits),
            value: "#{@current_project_characteristics.sum :visits}",
            data: @current_project_characteristics.send(scope).sum(:visits)
        },
        items_in_stock_number: {
            diff: diff_sum(:items_in_stock_number),
            value: "#{@current_project_characteristics.sum :items_in_stock_number}",
            data: @current_project_characteristics.send(scope).sum(:items_in_stock_number)
        },
        percentage_of_inventory_sold: {
            diff: diff_average_sum(:percentage_of_inventory_sold),
            value: "#{average_sum(@current_project_characteristics, :percentage_of_inventory_sold)}",
            data: @current_project_characteristics.send(scope).sum(:percentage_of_inventory_sold)
        },
        percentage_of_stock_sold: {
            diff: diff_average_sum(:percentage_of_stock_sold),
            value: "#{average_sum(@current_project_characteristics, :percentage_of_stock_sold)}",
            data: @current_project_characteristics.send(scope).sum(:percentage_of_stock_sold)
        },
        shipping_cost_as_a_percentage_of_total_revenue: {
            diff: diff_average_sum(:shipping_cost_as_a_percentage_of_total_revenue),
            value: "#{average_sum @current_project_characteristics, :shipping_cost_as_a_percentage_of_total_revenue}",
            data: @current_project_characteristics.send(scope).sum(:shipping_cost_as_a_percentage_of_total_revenue)
        }
    }

    result.each {|k, v| result[k][:data] = v[:data].map {|k, v| {'date' => k, 'close' => v}}}
    # result.each {|k, v| result[k][:data] = v[:data].reverse}

    result.merge({
        ratio_of_new_customers_to_repeat_customers: {
            diff: diff_values(@current_project_characteristics.sum(:new_customers_number).to_f / @current_project_characteristics.sum(:repeat_customers_number).to_f * 100.0, @previous_project_characteristics.sum(:new_customers_number).to_f / @previous_project_characteristics.sum(:repeat_customers_number).to_f * 100.0),
            value: "#{ration}",
            data: [
                {
                    color: "#91E873",
                    name: "New",
                    value: @current_project_characteristics.sum(:new_customers_number)
                },
                {
                    color: "#889FCC",
                    name: "Repeat",
                    value: @current_project_characteristics.sum(:repeat_customers_number)
                }
            ]
        }
    })
  end

  def ration
    result = (@current_project_characteristics.sum(:new_customers_number).to_f / @current_project_characteristics.sum(:repeat_customers_number).to_f * 100.0)
    (result.nan? || result.infinite?) ? result : result.round(1)
  end

  def big_charts_data
    scope = "group_date_by_#{period}"
    result = [
        {
            "name": "Revenue",
        "color": "#6AFFCB",
        "value": "#{@current_project_characteristics.sum :total_gross_revenues}$",
        "diff": diff_sum(:total_gross_revenues),
        "data": @current_project_characteristics.send(scope).sum(:total_gross_revenues)
    },
        {
            "name": "Orders",
        "color": "#FF1FA7",
        "value": "#{@current_project_characteristics.sum :orders_number}",
        "diff": diff_sum(:orders_number),
        "data": @current_project_characteristics.send(scope).sum(:orders_number)
    },
        {
            "name": "Products sell",
        "color": "#FF7045",
        "value": "#{@current_project_characteristics.sum :products_number}",
        "diff": diff_sum(:products_number),
        "data": @current_project_characteristics.send(scope).sum(:products_number)
    },
        {
            "name": "Unic users",
        "color": "#3BD7FF",
        "value": "#{@current_project_characteristics.sum :unique_users_number}",
        "diff": diff_sum(:unique_users_number),
        "data": @current_project_characteristics.send(scope).sum(:unique_users_number)
    },
        {
            "name": "Customers",
        "color": "#FFD865",
        "value": "#{@current_project_characteristics.sum :customers_number}",
        "diff": diff_sum(:customers_number),
        "data": @current_project_characteristics.send(scope).sum(:customers_number)
    }
    ]

    result.each {|gr| gr[:data] = gr[:data].map {|k, v| {'date' => k, 'close' => v}}}

    result
  end
end

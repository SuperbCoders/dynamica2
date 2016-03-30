class ChartsDataController < ApplicationController
  before_action :set_project
  before_action :authenticate_user!
  before_action :set_chart_data, only: [:big_chart_data, :other_chart_data, :full_chart_data, :sorted_chart_data, :full_chart_check_points]

  include ActionView::Helpers::NumberHelper

  respond_to :json

  def big_chart_data
    render json: big_charts_data(@current_project_characteristics, @previous_project_characteristics)
  end

  def other_chart_data
    render json: other_charts_data(@current_project_characteristics, @previous_project_characteristics)
  end

  def full_chart_data
    @chart = params[:chart]
    @result = {}

    @result[:full] = send(params[:chart], period, @current_project_characteristics, @previous_project_characteristics)
    @result[:full][:data] = round_close(@result[:full][:data])
    @result[:check_points] = full_chart_check_points
    render json: @result
  end

  def full_chart_check_points
    result = {}

    curr_date_from = date_from - 12.month
    curr_date_to = (date_from - 11.month)

    # logger.info "Current date_from #{curr_date_from} to #{curr_date_to}"
    current = @project.project_characteristics.where(date: curr_date_from..curr_date_to)
    prev = @project.project_characteristics.where(date: date_from - 13.month..(date_from - 12.month))
    result[:year_ago] = send(params[:chart], period, current, prev)

    curr_date_from = date_from - 6.month
    curr_date_to = (date_from - 5.month)

    # logger.info "Current date_from #{curr_date_from} to #{curr_date_to}"
    current = @project.project_characteristics.where(date: curr_date_from..curr_date_to)
    prev = @project.project_characteristics.where(date: date_from - 7.month..(date_from - 7.month))
    result[:half_a_year_ago] = send(params[:chart], period,  current, prev)

    curr_date_from = date_from - 3.month
    curr_date_to = (date_from - 2.month)

    # logger.info "Current date_from #{curr_date_from} to #{curr_date_to}"
    current = @project.project_characteristics.where(date: curr_date_from..curr_date_to)
    prev = @project.project_characteristics.where(date: date_from - 4.month..(date_from - 2.month))
    result[:three_month_ago] = send(params[:chart], period,  current, prev)

    curr_date_from = date_from - 1.month
    curr_date_to = (date_from)

    # logger.info "Current date_from #{curr_date_from} to #{curr_date_to}"
    current = @project.project_characteristics.where(date: curr_date_from..curr_date_to)
    prev = @project.project_characteristics.where(date: date_from - 2.month..(date_from - 1.month))
    result[:month_ago] = send(params[:chart], period,  current, prev)

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

  def set_chart_data
    @current_project_characteristics  = @project.project_characteristics.where(date: date_from..date_to)
    @previous_project_characteristics = @project.project_characteristics.where(date: (date_from - (date_to - date_from))...date_from)
  end

  def date_from
    @date_from ||= "#{params[:from][3..4]}.#{params[:from][0..1]}.#{params[:from][-4..-1]}".to_datetime
  end

  def date_to
    @date_to ||= "#{params[:to][3..4]}.#{params[:to][0..1]}.#{params[:to][-4..-1]}".to_datetime
  end

  def period
    params[:period] ? "group_date_by_#{params[:period]}" : 'group_date_by_day'
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

  def diff_sum(field, current_data, prev_data)
    diff_values current_data.sum(field), prev_data.sum(field) .round(2)
  end

  def diff_average_sum(field, current_data, prev_data)
    diff_values(average_sum(current_data, field), average_sum(prev_data, field))
  end

  def round_close(data)
    data.map {|k, v| {'date' => k, 'close' => v.round(2)}}
  end

  Dynamica::CHART_TYPES.each do |chart_type|
    define_method chart_type do |scope, current_data, prev_data|
      {
          diff: diff_sum(chart_type, current_data, prev_data),
          value: "#{current_data.sum(chart_type).round(2)}$",
          data: current_data.send(scope).sum(chart_type)
      }
    end
  end

  def other_charts_data(current_data, prev_data)
    scope = period
    result = {
        total_revenu: {
            diff: diff_sum(:total_gross_revenues, current_data, prev_data),
            value: "#{current_data.sum :total_gross_revenues}$",
            data: current_data.send(scope).sum(:total_gross_revenues)
        },
        products_number: {
            diff: diff_sum(:products_number, current_data, prev_data),
            value: "#{current_data.sum :products_number}",
            data: current_data.send(scope).sum(:products_number)
        },
        average_order_value: {
            diff: diff_average_sum(:average_order_value, current_data, prev_data),
            value: "#{average_sum current_data, :average_order_value}",
            data: current_data.send(scope).sum(:average_order_value)
        },
        average_order_size: {
            diff: diff_average_sum(:average_order_size, current_data, prev_data),
            value: "#{average_sum current_data, :average_order_size}",
            data: current_data.send(scope).sum(:average_order_size)
        },
        customers_number: {
            diff: diff_sum(:customers_number, current_data, prev_data),
            value: "#{current_data.sum :customers_number}",
            data: current_data.send(scope).sum(:customers_number)
        },
        new_customers_number: {
            diff: diff_sum(:new_customers_number, current_data, prev_data),
            value: "#{current_data.sum :new_customers_number}",
            data: current_data.send(scope).sum(:new_customers_number)
        },
        repeat_customers_number: {
            diff: diff_sum(:repeat_customers_number, current_data, prev_data),
            value: "#{current_data.sum :repeat_customers_number}",
            data: current_data.send(scope).sum(:repeat_customers_number)
        },
        average_revenue_per_customer: {
            diff: diff_average_sum(:average_revenue_per_customer, current_data, prev_data),
            value: "#{average_sum(current_data, :average_revenue_per_customer)}",
            data: current_data.send(scope).sum(:average_revenue_per_customer)
        },
        products_in_stock_number: {
            diff: diff_sum(:products_in_stock_number, current_data, prev_data),
            value: "#{current_data.sum :products_in_stock_number}",
            data: current_data.send(scope).sum(:products_in_stock_number)
        },
        sales_per_visitor: {
            diff: diff_sum(:sales_per_visitor, current_data, prev_data),
            value: "#{current_data.sum :sales_per_visitor}",
            data: current_data.send(scope).sum(:sales_per_visitor)
        },
        average_customer_lifetime_value: {
            diff: diff_sum(:average_customer_lifetime_value, current_data, prev_data),
            value: "#{current_data.sum :average_customer_lifetime_value}",
            data: current_data.send(scope).sum(:average_customer_lifetime_value)
        },
        unique_users_number: {
            diff: diff_sum(:unique_users_number, current_data, prev_data),
            value: "#{current_data.sum :unique_users_number}",
            data: current_data.send(scope).sum(:unique_users_number)
        },
        visits: {
            diff: diff_sum(:visits, current_data, prev_data),
            value: "#{current_data.sum :visits}",
            data: current_data.send(scope).sum(:visits)
        },
        items_in_stock_number: {
            diff: diff_sum(:items_in_stock_number, current_data, prev_data),
            value: "#{current_data.sum :items_in_stock_number}",
            data: current_data.send(scope).sum(:items_in_stock_number)
        },
        percentage_of_inventory_sold: {
            diff: diff_average_sum(:percentage_of_inventory_sold, current_data, prev_data),
            value: "#{average_sum(current_data, :percentage_of_inventory_sold)}",
            data: current_data.send(scope).sum(:percentage_of_inventory_sold)
        },
        percentage_of_stock_sold: {
            diff: diff_average_sum(:percentage_of_stock_sold, current_data, prev_data),
            value: "#{average_sum(current_data, :percentage_of_stock_sold)}",
            data: current_data.send(scope).sum(:percentage_of_stock_sold)
        },
        shipping_cost_as_a_percentage_of_total_revenue: {
            diff: diff_average_sum(:shipping_cost_as_a_percentage_of_total_revenue, current_data, prev_data),
            value: "#{average_sum current_data, :shipping_cost_as_a_percentage_of_total_revenue}",
            data: current_data.send(scope).sum(:shipping_cost_as_a_percentage_of_total_revenue)
        }
    }

    result.each {|k, v| result[k][:data] = v[:data].map {|k, v| {'date' => k, 'close' => v}}}
    
    result.each { |k, chart_data|
      temp_data = result[k][:data]
      result[k][:data] = []
      temp_data.each_slice(temp_data.length / 8) do |e, *_|
        result[k][:data] << e
      end

    }
    
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

  def big_charts_data(current_data, prev_data)
    scope = period
    result = [
        {
            "name": "Revenue",
            "tr_name": "revenue",
            "color": "#6AFFCB",
            "value": "#{current_data.sum :total_gross_revenues}$",
            "diff": diff_sum(:total_gross_revenues, current_data, prev_data),
            "data": current_data.send(scope).sum(:total_gross_revenues)
        },
        {
            "name": "Orders",
            "tr_name": "orders",
            "color": "#FF1FA7",
            "value": "#{current_data.sum :orders_number}",
            "diff": diff_sum(:orders_number, current_data, prev_data),
            "data": current_data.send(scope).sum(:orders_number)
        },
        {
            "name": "Products sell",
            "tr_name": "products_sell",
            "color": "#FF7045",
            "value": "#{current_data.sum :products_number}",
            "diff": diff_sum(:products_number, current_data, prev_data),
            "data": current_data.send(scope).sum(:products_number)
        },
        {
            "name": "Unic users",
            "tr_name": "unic_users",
            "color": "#3BD7FF",
            "value": "#{current_data.sum :unique_users_number}",
            "diff": diff_sum(:unique_users_number, current_data, prev_data),
            "data": current_data.send(scope).sum(:unique_users_number)
        },
        {
            "name": "Customers",
            "tr_name": "customers",
            "color": "#FFD865",
            "value": "#{current_data.sum :customers_number}",
            "diff": diff_sum(:customers_number, current_data, prev_data),
            "data": current_data.send(scope).sum(:customers_number)
        }
    ]

    result.each {|gr| gr[:data] = gr[:data].map {|k, v| {'date' => k, 'close' => v}}}

    result
  end
end

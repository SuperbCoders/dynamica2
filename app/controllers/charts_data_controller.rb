class ChartsDataController < ApplicationController
  before_action :set_project
  before_action :authenticate_user!

  def big_chart_data
    @current_project_characteristics  = @project.project_characteristics.where(date: date_from..date_to)
    @previous_project_characteristics = @project.project_characteristics.where(date: (date_from - (date_to - date_from))..date_from)

    render json: big_charts_data
  end

  private

  def date_from
    @date_from ||= Date.parse params[:from]
  end

  def date_to
    @date_to ||= Date.parse params[:to]
  end

  def set_project
    @project = current_user.projects.where(id: params[:project_id]).first
  end

    def diff(current_value, previous_value)
    result = current_value * 100.0 / previous_value - 100
    result > 0 ? "+#{result}" : result
  end

  def big_charts_data()
    result = {
      day: [
        {
            "name": "Revenue",
            "color": "#6AFFCB",
            "value": "#{@current_project_characteristics.sum :total_gross_revenues}$",
            "diff": "+8%",
            "data": @current_project_characteristics.group_date_by_day.sum(:total_gross_revenues)
        },
        {
            "name": "Orders",
            "color": "#FF1FA7",
            "value": "#{@current_project_characteristics.sum :orders_number}",
            "diff": "+10%",
            "data": @current_project_characteristics.group_date_by_day.sum(:orders_number)
        },
        {
            "name": "Products sell",
            "color": "#FF7045",
            "value": "#{@current_project_characteristics.sum :products_number}",
            "diff": "+8%",
            "data": @current_project_characteristics.group_date_by_day.sum(:products_number)
        },
        {
            "name": "Unic users",
            "color": "#3BD7FF",
            "value": "#{@current_project_characteristics.sum :unique_users_number}",
            "diff": "+8%",
            "data": @current_project_characteristics.group_date_by_day.sum(:unique_users_number)
        },
        {
            "name": "Customers",
            "color": "#FFD865",
            "value": "#{@current_project_characteristics.sum :customers_number}",
            "diff": "+8%",
            "data": @current_project_characteristics.group_date_by_day.sum(:customers_number)
        }
      ],
      week: [
        {
            "name": "Revenue",
            "color": "#6AFFCB",
            "value": @current_project_characteristics.sum(:total_gross_revenues),
            "diff": diff(@current_project_characteristics.sum(:total_gross_revenues), @previous_project_characteristics.sum(:total_gross_revenues)),
            "data": @current_project_characteristics.group_date_by_week.sum(:total_gross_revenues)
        },
        {
            "name": "Orders",
            "color": "#FF1FA7",
            "value": @current_project_characteristics.sum(:orders_number),
            "diff": diff(@current_project_characteristics.sum(:orders_number), @previous_project_characteristics.sum(:orders_number)),
            "data": @current_project_characteristics.group_date_by_week.sum(:orders_number)
        },
        {
            "name": "Products sell",
            "color": "#FF7045",
            "value": @current_project_characteristics.sum(:orders_number),
            "diff": diff(@current_project_characteristics.sum(:orders_number), @previous_project_characteristics.sum(:orders_number)),
            "data": @current_project_characteristics.group_date_by_week.sum(:orders_number)
        },
        {
            "name": "Unic users",
            "color": "#3BD7FF",
            "value": @current_project_characteristics.sum(:unique_users_number),
            "diff": diff(@current_project_characteristics.sum(:unique_users_number), @previous_project_characteristics.sum(:unique_users_number)),
            "data": @current_project_characteristics.group_date_by_week.sum(:unique_users_number)
        },
        {
            "name": "Customers",
            "color": "#FFD865",
            "value": @current_project_characteristics.sum(:customers_number),
            "diff": diff(@current_project_characteristics.sum(:customers_number), @previous_project_characteristics.sum(:customers_number)),
            "data": @current_project_characteristics.group_date_by_week.sum(:customers_number)
        }
      ],
      month: [
        {
            "name": "Revenue",
            "color": "#6AFFCB",
            "value": @current_project_characteristics.sum(:total_gross_revenues),
            "diff": diff(@current_project_characteristics.sum(:total_gross_revenues), @previous_project_characteristics.sum(:total_gross_revenues)),
            "data": @current_project_characteristics.group_date_by_month.sum(:total_gross_revenues)
        },
        {
            "name": "Orders",
            "color": "#FF1FA7",
            "value": @current_project_characteristics.sum(:orders_number),
            "diff": diff(@current_project_characteristics.sum(:orders_number), @previous_project_characteristics.sum(:orders_number)),
            "data": @current_project_characteristics.group_date_by_month.sum(:orders_number)
        },
        {
            "name": "Products sell",
            "color": "#FF7045",
            "value": @current_project_characteristics.sum(:orders_number),
            "diff": diff(@current_project_characteristics.sum(:orders_number), @previous_project_characteristics.sum(:orders_number)),
            "data": @current_project_characteristics.group_date_by_month.sum(:orders_number)
        },
        {
            "name": "Unic users",
            "color": "#3BD7FF",
            "value": @current_project_characteristics.sum(:unique_users_number),
            "diff": diff(@current_project_characteristics.sum(:unique_users_number), @previous_project_characteristics.sum(:unique_users_number)),
            "data": @current_project_characteristics.group_date_by_month.sum(:unique_users_number)
        },
        {
            "name": "Customers",
            "color": "#FFD865",
            "value": @current_project_characteristics.sum(:customers_number),
            "diff": diff(@current_project_characteristics.sum(:customers_number), @previous_project_characteristics.sum(:customers_number)),
            "data": @current_project_characteristics.group_date_by_month.sum(:customers_number)
        }
      ]
    }

    result[:day].each {|gr| gr[:data] = gr[:data].map {|k, v| {'date' => Date.parse(k).strftime("%d-%b-%y"), 'close' => v}}}

    result[:day]
  end
end

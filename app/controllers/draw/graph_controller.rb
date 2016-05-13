class Draw::GraphController < ActionController::Base
  layout 'draw'

  before_action :set_data, only: [:donut, :block, :big]
  before_action :normalize_result, only: [:block, :big]

  def block

  end

  def donut

  end

  def big

  end

  def normalize_result
    @result[:data] = @result[:data].map {|k, v| {'date' => k, 'close' => v}}
  end

  def set_data
    if project
      @data = project.project_characteristics.where(date: date_from..date_to)
      @prev_data = project.project_characteristics.where(date: (date_from - (date_to - date_from))...date_from)

      case graph_params[:chart]
        when 'order_statuses'
          @result = project.order_statuses(date_from, date_to)
        when 'products_in_stock_number'
          @result = project.send(params[:chart], date_from, date_to)
        else
          @result = project.send(params[:chart], period, @data, @prev_data)
      end

    end
  end

  private

  def graph_params
    params.permit(:project_id, :from, :to, :chart)
  end

  def period
    graph_params[:period] ? "group_date_by_#{graph_params[:period]}" : 'group_date_by_day'
  end


  def date_from
    @date_from ||= graph_params[:from].to_datetime
  end

  def date_to
    @date_to ||= graph_params[:to].to_datetime
  end

  def project
    Project.find(graph_params[:project_id])
  end
end

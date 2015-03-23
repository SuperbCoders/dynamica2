module Stats
  class Forecast
    attr_reader :item, :period, :depth, :from, :to, :group_method

    def initialize(item, options = {})
      @item = item

      @period = options[:period].try(:to_sym) || :day
      @depth = options[:depth] || 5
      @from = UTC.parse(options[:from] || Date.today.ago(1.year))
      @to = UTC.parse(options[:to] || Date.today)
      @group_method = options[:group_method].try(:to_sym) || :sum

      @postgres_mapping = Stats::PostgresMapping.new(period, group_method)

      case @period
      when :hour
        @from = @from.beginning_of_hour
        @to = @to.end_of_hour
        @interval = -> (date) { date + 1.hour }
      when :day, :week
        @from = @from.beginning_of_day
        @to = @to.end_of_day
        @interval = -> (date) { date + 1.day }
      when :week
        @from = @from.beginning_of_day
        @to = @to.end_of_day
        @interval = -> (date) { date + 7.days }
      when :month
        @from = @from.beginning_of_month
        @to = @to.end_of_month
        @interval = -> (date) { date.next_month.beginning_of_month }
      when :quarter
        @from = @from.beginning_of_month
        @to = @to.end_of_month
        @interval = -> (date) { (date + 3.month).beginning_of_month }
      when :year
        @from = @from.beginning_of_year
        @to = @to.end_of_year
        @interval = -> (date) { date.next_year.beginning_of_year }
      end
    end

    def calculate
      R.eval 'library(forecast)'
      R.myvector = series_values
      R.eval %Q(
        myts <- ts(myvector)
        fit <- auto.arima(myts)
        prediction <- forecast(fit, #{depth})
        tmp <- as.numeric(prediction$mean)
      )
      prediction = R.pull('tmp')
      values = {}
      [prediction].flatten.each_with_index do |e, i|
        key = @to
        (i + 1).times { key = @interval.call(key) }
        values[to_value(key)] = e
      end
      values
    end

    def series
      @series ||= calculate_series
    end

    def series_values
      @series_values ||= series.map do |serie|
        serie['value'].to_f
      end
    end

    private
    
      def calculate_series
        query = <<-EOS
          SELECT
            series AS start,
            #{@postgres_mapping.interval_end} AS end,
            (
              SELECT #{@postgres_mapping.group_method}
              FROM values
              WHERE
                item_id = '#{item.id}' AND
                timestamp >= series AND
                timestamp <= #{@postgres_mapping.interval_end}
            ) AS value
          FROM generate_series('#{@from.to_s(:db)}'::timestamp, '#{@to.to_s(:db)}'::timestamp, '#{@postgres_mapping.interval_step}') AS series
        EOS
        puts query
        ActiveRecord::Base.connection.execute(query).to_a
      end

      # Converts date to hash with :from, :to and :timestamp values
      # @param date [Time] orignial date
      # @return [Hash] { from: [Time], to: [Time] }
      def to_value(date)
        case @period
        when :hour then { from: date.beginning_of_hour, to: date.end_of_hour }
        when :day then { from: date.beginning_of_day, to: date.end_of_day }
        when :week then { from: date.beginning_of_day, to: (date.beginning_of_day + 1.week - 1.day).end_of_day }
        when :month then { from: date.beginning_of_month, to: date.end_of_month }
        when :quarter then { from: date.beginning_of_month, to: (date.beginning_of_month + 2.months).end_of_month } # @todo: check!
        when :year then { from: date.beginning_of_year, to: date.end_of_year }
        end
      end


  end
end
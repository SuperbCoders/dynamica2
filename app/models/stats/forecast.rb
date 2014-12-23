module Stats
  class Forecast
    attr_reader :item, :period, :depth, :from, :to, :group_method

    def initialize(item, options = {})
      @item = item

      @period = options[:period].try(:to_sym) || :day
      @depth = options[:depth] || 5
      @from = options[:from].try(:to_time).try(:utc) || Date.today.ago(1.year).to_time.utc
      @to = options[:to].try(:to_time).try(:utc) || Date.today.to_time.utc
      @group_method = options[:group_method].try(:to_sym) || :sum

      @interval = case @period
      when :day then -> (date) { date.to_time.utc + 1.day }
      when :month then -> (date) { date.to_time.utc.next_month.beginning_of_month }
      end

      @time_format = case @period
      when :day then '%Y-%m-%d'
      when :month then '%Y-%m'
      end

      @sql_format = case @period
      when :day then 'YYYY-MM-DD'
      when :month then 'YYYY-MM'
      end
    end

    def series
      @series ||= series_with_timestamps.values
    end

    def series_with_timestamps
      result = {}
      series_dates.each do |date|
        result[date] = series_quantities[date[:timestamp]].to_f || 0
      end
      result
    end

    def calculate
      R.eval 'library(forecast)'
      R.myvector = series
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

    private

      def series_quantities
        @series_quantities ||= item.values.group("to_char(values.timestamp, '#{@sql_format}')").send(group_method, :value)
      end

      # Generates list of dates for time series
      # @return [Array<String>] list of dates
      def series_dates
        result = []
        date = @from.to_time.utc
        while date <= @to
          result << to_value(date)
          date = @interval.call(date)
        end
        result
      end

      # Converts date to hash with :from, :to and :timestamp values
      # @param date [Time] orignial date
      # @return [Hash] { from: [Time], to: [Time], timestamp: [String] }
      def to_value(date)
        case @period
        when :day then { from: date.beginning_of_day.utc, to: date.end_of_day.utc, timestamp: date.strftime('%Y-%m-%d') }
        when :month then { from: date.beginning_of_month.utc, to: date.end_of_month.utc, timestamp: date.strftime('%Y-%m') }
        end
      end

  end
end
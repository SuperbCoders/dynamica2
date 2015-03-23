# Describes how some values from real world should be mapped into Postgres queries
# E.g. how to generate series of dates grouped by hours
class Stats::PostgresMapping
  def initialize(period, group_method)
    @period = period
    @group_method = group_method
  end

  def interval_end
    @interval_end ||= case @period
    when :hour then "series + interval '1 hour' - interval '1 second'"
    when :day  then "series + interval '1 day' - interval '1 second'"
    when :week  then "series + interval '7 days' - interval '1 second'"
    when :month  then "series + interval '1 month' - interval '1 second'"
    when :quarter  then "series + interval '3 months' - interval '1 second'"
    when :year  then "series + interval '1 month' - interval '1 second'"
    end
  end

  def interval_step
    @interval_step ||= case @period
    when :hour then '1 hour'
    when :day then '1 day'
    when :week then '7 days'
    when :month then '1 month'
    when :quarter then '3 months'
    when :year then '1 year'
    end
  end

  def group_method
    case @group_method
    when :sum then 'SUM(value)'
    when :average then 'AVG(value)'
    when :min then 'MIN(value)'
    when :max then 'MAX(value)'
    end
  end
end

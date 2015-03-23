# This class provides ability to work with time without time zones dependency.
# It processes any date and time like it is in UTC format.
class UTC < Time
  DATETIME_REGEXP = /(\d\d\d\d)-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/

  # @return [Time] datetime without time zone information (in UTC)
  def self.parse(time)
    values = DATETIME_REGEXP.match(Time.parse(time.to_s).to_s)
    UTC.utc(values[1], values[2], values[3], values[4], values[5], values[6])
  end

  def to_s(format = nil)
    strftime('%Y-%m-%d %H:%M:%S')
  end
end

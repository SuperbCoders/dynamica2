module Dynamica
  # Class that provides ability to work with time
  # without time zones dependency.
  # It processes any date and time like it is in UTC format
  class UTC
    def self.parse(string)
      values = Time.parse(string).strftime('%d %m %Y %H %M %S').split(' ')
      Time.utc(values)
    end
  end
end

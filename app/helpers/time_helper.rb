module TimeHelper
  def ceil_time(time, seconds = 60)
    return time if seconds.zero?
    Time.at(((time - time.utc_offset).to_f / seconds).ceil * seconds).in_time_zone + time.utc_offset
  end
end

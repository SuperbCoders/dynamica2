module TimeHelper
  def ceil_time(time, seconds = 60)
    return time if seconds.zero?
    Time.at(((time - time.utc_offset).to_f / seconds).ceil * seconds).in_time_zone + time.utc_offset
  end

  def ceiled_time_in_words(time, seconds = 60)
    ceiled_time = ceil_time(time, seconds)
    if ceiled_time.future?
      distance_of_time_in_words(Time.now, ceiled_time)
    else
      I18n.t('forecasts.planned.moment')
    end
  end
end

module StatsHelper
  def self.generate_values(options = {})
    time = options[:from]
    while time <= options[:to]
      FactoryGirl.create(:value, item: options[:item], timestamp: time, value: options[:value])
      time += options[:interval]
    end
  end

  def self.generate_series(options = {})
    result = []
    time = UTC.parse(options[:from])
    while time <= options[:to]
      result << ({ 'start' => time.to_s(:db), 'end' => (time + options[:interval] - 1.second).to_s(:db), 'value' => options[:value].to_s })
      time += options[:interval]
    end
    result
  end
end

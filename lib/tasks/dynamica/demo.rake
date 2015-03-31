require 'csv'

namespace :dynamica do
  namespace :demo do
    task csv: :environment do
    end

    desc 'Generates demo CSV file with random data'
    task :csv, [:name, :from, :to, :interval] => :environment  do |t, args|
      args.with_defaults(name: 'carrot', from: '01.01.2013', to: Time.now.to_s, interval: 'random')
      from = UTC.parse(args.from)
      to = UTC.parse(args.to)
      interval = case args.interval
      when 'random' then :random
      when 'day' then 1.day
      else args.interval.to_i
      end
      time = from
      CSV.open("#{Rails.root}/db/seeds/#{args.name}.csv", "w") do |csv|
        while time <= to do
          time += interval == :random ? (10.minutes + rand(1.day)) : interval
          csv << [time.strftime('%d.%m.%Y %H:%M:%S'), rand(20) + 1]
        end
      end
    end
  end
end
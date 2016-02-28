class CharacteristicsUpdaterWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(2) }

  def perform()
    Project.actives.each { |project| project.fetch_data 1.day }
  end
end

class BaseWorker
  include Sidekiq::Worker

  attr_accessor :logger

  def self.logger
    @logger ||= ::Logger.new("#{Rails.root}/log/worker_#{self.name}.log")
  end
end

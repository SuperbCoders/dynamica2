class BaseWorker
  include Sidekiq::Worker

  attr_accessor :logger

  def logger
    @logger ||= ::Logger.new("#{Rails.root}/log/worker_#{self.class.name}.log")
  end
end

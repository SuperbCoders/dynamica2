require 'clockwork'
require 'config/boot'
require 'config/environment'

module Clockwork
  every(1.day,'ReportWorker called', :at => 'Sunday 11:45', :tz => 'UTC') { ReportWorker.perform_async }
end


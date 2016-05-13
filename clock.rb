require 'clockwork'
require 'config/boot'
require 'config/environment'

module Clockwork
  every(1.week,'ReportWorker called', :at => 'Sunday 11:45', :tz => 'UTC') { ReportWorker.perform_async }
end


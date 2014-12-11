namespace :dynamica do
  namespace :forecasts do
    task start_planned: :environment do
      Forecast.start_planned
    end
  end
end

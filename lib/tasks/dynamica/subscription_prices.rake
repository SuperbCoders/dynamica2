namespace :dynamica do
  namespace :subscription_prices do
    task init: :environment do
	    SubscriptionPrice.create(sub_type: 1, cost: 5)
	    SubscriptionPrice.create(sub_type: 2, cost: 49)
    end
  end
end
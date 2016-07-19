class SubscriptionPrice < ActiveRecord::Base
	enum sub_type: Dynamica::Billing::SUBSCRIPTION_TYPES

	validates :sub_type, uniqueness: true

	def title
		case sub_type
			when "monthly" then "Месячная"
			when "yearly"  then "Годовая"
		end
	end

	def self.save_percentage
		monthly_cost = SubscriptionPrice.monthly.first.cost
		yearly_cost  = SubscriptionPrice.yearly.first.cost

		((1-yearly_cost/(monthly_cost*12))*100).to_i.to_s
	end
end

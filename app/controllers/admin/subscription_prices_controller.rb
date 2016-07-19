class Admin::SubscriptionPricesController < Admin::ApplicationController
	def index
		@sub_prices = SubscriptionPrice.all
		@sub_prices = @sub_prices.page(params[:page]).per(50)
	end

	def edit
		@sub_price = SubscriptionPrice.find(params[:id])
	end

	def update
		@sub_price = SubscriptionPrice.find(params[:id])

		@sub_price.update(sub_price_params)

		redirect_to admin_subscription_prices_path
	end

	private
		def sub_price_params
			params.require(:subscription_price).permit(:cost)
		end
end

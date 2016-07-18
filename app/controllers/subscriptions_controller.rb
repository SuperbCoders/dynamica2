class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:change]
  before_action :get_project_by_charge_id, only: [:callback]
  before_action :find_charge_by_id, only: [:callback]

  respond_to :json

  def callback
    if @charge
      if @charge.status == 'accepted' and @charge.activate
        current_user.subscription.renew!
      end

      current_user.subscription_logs.where(charge_id: @charge.id).each do |charge_log|

        charge_log.status = @charge.status

        charge_log.save
      end
    end

    redirect_to dashboard_path
  end

  # Return project subscription and history
  def show
    @response[:subscription] = serialize_resource(current_user.subscription, SubscriptionSerializer)
    @response[:success] = true
    render json: @response
  end


  # Make charge
  def change
    if @project and @project.shopify_session

      case subscription_params[:sub_type]
        when 'monthly'
          charge = ShopifyAPI::ApplicationCharge.new(
              price: Dynamica::Billing::MONTHLY_PRICE,
              name: "Monthly billing $ #{Dynamica::Billing::MONTHLY_PRICE} for ##{@project.id}",
              charge_type: 'monthly')

          current_user.subscription.monthly!
        when 'yearly'
          charge = ShopifyAPI::RecurringApplicationCharge.new(
              price: Dynamica::Billing::YEARLY_PRICE,
              name: "Yearly billing $ #{Dynamica::Billing::YEARLY_PRICE} for ##{@project.id}",
              charge_type: 'yearly')

          current_user.subscription.yearly!
      end


      if charge
        charge.return_url = subscription_callback_url
        charge.test = true if Rails.env.development? or Rails.env.staging?
        charge.save
        set_project_by_charge_id(charge.id, @project.id)
        @response[:charge] = charge
        @response[:success] = true

        current_user.subscription_logs.create(
            charge_id: charge.id,
            description: "Change subscription to #{subscription_params[:sub_type]}. Charge_id #{charge.id}")
      end

    else
      @response[:errors] << t('projects.subscriptions.shopify_not_integrated') if not @project.shopify?

    end

    if params[:redirect] == 'true'
      redirect_to charge.confirmation_url and return
    end

    render json: @response ||= {}
  end

  private

  # Find charge from shopify api by charge_id and project subscription type
  def find_charge_by_id
    if @project and @project.shopify_session
      case current_user.subscription.sub_type
        when 'monthly'
          @charge = ShopifyAPI::ApplicationCharge.find(params[:charge_id])
        when 'yearly'
          @charge = ShopifyAPI::RecurringApplicationCharge.find(params[:charge_id])
      end
    end
  end

  # Get project id by charge_id from redis
  def get_project_by_charge_id
    data = $redis.hgetall("charges:#{params[:charge_id]}")
    @project = data['project_id'] ? current_user.projects.find(data['project_id']) : nil
  end

  # Set project id by charge_id from redis
  def set_project_by_charge_id(charge_id, project_id)
    $redis.mapped_hmset "charges:#{charge_id}", {project_id: project_id}
  end

  def subscription_params
    params.permit(:id, :sub_type, :project_id)
  end

  def set_project
    @project = Project.find(subscription_params[:project_id])
  end
end

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :change]
  before_action :get_project_by_charge_id, only: [:callback]
  before_action :find_charge_by_id, only: [:callback]

  respond_to :json

  def callback
    if @project and @charge
      if @charge.status == 'accepted' and @charge.activate
        @project.subscription.renew!
      end
    end

    redirect_to dashboard_path
  end

  # Return project subscription and history
  def show
    if @project
      @response[:subscription] = serialize_resource(@project.subscription, SubscriptionSerializer)
      if not Rails.env.test? and @project.shopify_session
        @response[:success] = true
        case @project.sub_type
          when 'monthly' then @response[:history] = ShopifyAPI::ApplicationCharge.all
          when 'yearly' then @response[:history] = ShopifyAPI::RecurringApplicationCharge.all
        end
      end
    end

    puts @response
    render json: @response
  end

  # Make charge
  def change
    if @project and @project.shopify_session

      logger.info "Subscription type #{project_params[:sub_type]}"

      case project_params[:sub_type]
        when 'monthly'
          charge = ShopifyAPI::ApplicationCharge.new(
              price: Dynamica::Billing::MONTHLY_PRICE,
              name: "Monthly billing $ #{Dynamica::Billing::MONTHLY_PRICE} for ##{@project.id}",
              charge_type: 'monthly')
        when 'yearly'
          charge = ShopifyAPI::RecurringApplicationCharge.new(
              price: Dynamica::Billing::YEARLY_PRICE,
              name: "Yearly billing $ #{Dynamica::Billing::YEARLY_PRICE} for ##{@project.id}",
              charge_type: 'yearly')
      end


      if charge
        case project_params[:sub_type]
          when 'monthly'
            @project.subscription.monthly!
            @response[:history] = ShopifyAPI::ApplicationCharge.all
          when 'yearly'
            @project.subscription.yearly!
            @response[:history] = ShopifyAPI::RecurringApplicationCharge.all
        end

        charge.return_url = subscription_callback_url
        charge.test = true if Rails.env.development? or Rails.env.staging?
        charge.save
        set_project_by_charge_id(charge.id, @project.id)
        @response[:charge] = charge
        @response[:success] = true
      end

    else
      @response[:errors] << t('projects.subscriptions.shopify_not_integrated') if not @project.shopify?

    end



    render json: @response ||= {}
  end

  private

  # Find charge from shopify api by charge_id and project subscription type
  def find_charge_by_id
    if @project and @project.shopify_session
      case @project.sub_type
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

  def project_params
    params.permit(:id, :sub_type)
  end

  def set_project
    @project = Project.find(project_params[:id])
  end
end

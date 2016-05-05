require 'rails_helper'

RSpec.describe SubscriptionsController, :type => :controller do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

  describe 'GET #show' do
    context 'with not expired project' do
      before { get :show, format: :json }

      it 'should return not expired trial subscription' do
        expect_json('subscription', sub_type: 'trial')
        expect_json('subscription', expired?: false)
      end
    end

    context 'with expired trial subscription' do
      before { user.subscription.update_attributes(expire_at: 1.year.ago) }
      it 'should return expired subscription' do
        get :show, format: :json

        expect_json('subscription', sub_type: 'trial')
        expect_json('subscription', expired?: true)
      end
    end
  end
end

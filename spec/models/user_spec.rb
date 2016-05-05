require 'rails_helper'

RSpec.describe User, :type => :model do
  # Attributes
  it { is_expected.to respond_to(:name, :avatar, :role) }

  # Relations
  it { is_expected.to have_one(:subscription) }
  it { is_expected.to have_many(:subscription_logs) }
  it { is_expected.to have_many(:own_projects).dependent(:restrict_with_error) }


  user = FactoryGirl.create(:user)

  it 'should create subscription for new user' do
    expect(user.subscription).not_to be_nil
  end

  it 'new subscription should trial for new user' do
    expect(user.subscription.type).to eq 'trial'
  end

end

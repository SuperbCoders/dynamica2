require 'rails_helper'

RSpec.describe Subscription, :type => :model do

  # Attributes
  it { is_expected.to respond_to(:sub_type, :expire_at) }


  # Relations
  it { is_expected.to belong_to(:user) }

  # Validations
  it { is_expected.to validate_presence_of(:user) }


  let(:subscription) { FactoryGirl.create(:user).subscription }

  describe '#type' do
    it 'should be trial for new project' do
      expect(subscription.type).to eq 'trial'
    end
  end

  describe '#monthly!' do
    it 'should be monthly for monthly subscription' do
      subscription.monthly!
      expect(subscription.type).to eq 'monthly'
    end
  end

  describe '#yearly!' do
    it 'should be yearly for yearly subscription' do
      subscription.yearly!
      expect(subscription.type).to eq 'yearly'
    end
  end

  describe '#expired?' do
    it 'should return false for expired subscription' do
      expect(subscription.expired?).to be_falsey
    end

    it 'should return true for expired subscription' do
      subscription.update_attributes(expire_at: 1.year.ago)
      expect(subscription.expired?).to be_truthy
    end
  end

end

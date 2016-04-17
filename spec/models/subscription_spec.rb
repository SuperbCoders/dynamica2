require 'rails_helper'

RSpec.describe Subscription, :type => :model do
  it { is_expected.to respond_to(:sub_type, :expire_at) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:project) }


  user = FactoryGirl.create(:user)
  project =  FactoryGirl.create(:project, user: user)
  user.permissions.create(project: project, all: true)

  describe '#type' do
    it 'should return trial for new project' do
      expect(project.subscription.type).to eq 'trial'
    end

    it 'should return monthly for monthly subscription' do
      project.subscription.monthly!
      expect(project.subscription.type).to eq 'monthly'
    end

    it 'should return yearly for monthly subscription' do
      project.subscription.yearly!
      expect(project.subscription.type).to eq 'yearly'
    end
  end

  describe '#expired?' do
    before { project =  FactoryGirl.create(:project, user: user) }

    it 'should return false for new project' do
      expect(project.subscription.expired?).to be_falsey
    end

    it 'should return true for expired project' do
      project.subscription.update_attributes(expire_at: 1.year.ago)
      expect(project.subscription.expired?).to be_truthy
    end
  end

end

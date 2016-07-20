require 'rails_helper'

RSpec.describe SubscriptionPrice, :type => :model do
  it "should be invalid with non-digital cost" do
  	expect(SubscriptionPrice.create(sub_type: 0, cost: "qw11e")).not_to be_valid
  end

  it "should be valid with digital cost" do
  	expect(SubscriptionPrice.create(sub_type: 0, cost: 11.2)).to be_valid
  end

  it "should be invalid without cost" do
  	expect(SubscriptionPrice.create(sub_type: 0)).not_to be_valid
  end
end

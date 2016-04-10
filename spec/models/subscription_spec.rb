require 'rails_helper'

RSpec.describe Subscription, :type => :model do
  it { is_expected.to respond_to(:date) }
  # it { is_expected.to belong_to(:user) }
  # it { is_expected.to belong_to(:project) }
  # it { is_expected.to validate_presence_of(:project)  }
end

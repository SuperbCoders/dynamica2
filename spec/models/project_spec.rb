require 'rails_helper'

RSpec.describe Project, :type => :model do

  # Attributes
  it { is_expected.to respond_to(:slug, :name, :api_used, :demo, :guest_token)}
  it { is_expected.to belong_to(:user) }

  # Associations
  it { is_expected.to have_many(:project_characteristics).dependent(:destroy) }
  it { is_expected.to have_many(:project_order_statuses).dependent(:destroy) }
  it { is_expected.to have_many(:product_characteristics).dependent(:destroy) }
  it { is_expected.to have_many(:products).dependent(:destroy) }
end

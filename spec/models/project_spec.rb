# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  slug        :string(255)
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#  api_used    :boolean          default(FALSE)
#  demo        :boolean          default(FALSE)
#  guest_token :string(255)
#

require 'rails_helper'

RSpec.describe Project, :type => :model do

  # # Attributes
  # it { is_expected.to respond_to(:slug, :name, :api_user, :demo, :guest_token)}
  # it { is_expected.to belong_to(:user) }
  #
  # # Associations
  # it { is_expected.to have_many(:order_statuses).dependent(:destroy) }
  # it { is_expected.to have_many(:financial_statuses).dependent(:destroy) }
  # it { is_expected.to have_many(:project_characteristics).dependent(:destroy) }

end

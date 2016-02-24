# == Schema Information
#
# Table name: integrations
#
#  id           :integer          not null, primary key
#  project_id   :integer          not null
#  code         :string(255)
#  access_token :string(255)
#  type         :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#

class Integration < ActiveRecord::Base
  validates :project_id, presence: true
  validates :type, presence: true

  belongs_to :project

  ORDER_FIELDS = [
    # :id,
    # :name,
    # :line_items
  ].freeze

  # CUSTOMER_FIELDS = [
  # ].freeze

  PRODUCT_FIELDS = [
  ].freeze

  def fetch(date_from, date_to)
    raise NotImplementedError, 'Subclasses must define `fetch`.'
  end

  after_commit :fetch_data, on: [:create, :update]

  protected

  def get_data
    raise NotImplementedError, 'Subclasses must define `get_data`.'
  end

  def fetch_data
    self.project.fetch_data
  end
end

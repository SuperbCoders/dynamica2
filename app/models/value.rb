# == Schema Information
#
# Table name: values
#
#  id         :integer          not null, primary key
#  item_id    :integer
#  value      :float
#  timestamp  :datetime
#  created_at :datetime
#  updated_at :datetime
#

class Value < ActiveRecord::Base
  belongs_to :item, counter_cache: true

  validates :item, presence: true
  validates :value, presence: true
  validates :timestamp, presence: true

  self.skip_time_zone_conversion_for_attributes = [:timestamp]
end

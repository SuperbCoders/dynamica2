class Value < ActiveRecord::Base
  belongs_to :item, counter_cache: true

  validates :item, presence: true
  validates :value, presence: true
  validates :timestamp, presence: true

  self.skip_time_zone_conversion_for_attributes = [:timestamp]
end

class PredictedValue < ActiveRecord::Base
  belongs_to :forecast

  validates :forecast, presence: true
  validates :value, presence: true
  validates :timestamp, presence: true, uniqueness: { scope: :forecast_id }
end

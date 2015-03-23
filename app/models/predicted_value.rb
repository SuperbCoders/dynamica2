class PredictedValue < ActiveRecord::Base
  belongs_to :forecast_line

  validates :forecast_line, presence: true
  validates :value, presence: true
  validates :from, presence: true
  validates :to, presence: true

  def to_flot
    [from.to_i * 1000, value]
  end
end

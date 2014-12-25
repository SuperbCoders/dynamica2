class PredictedValue < ActiveRecord::Base
  belongs_to :forecast_line

  validates :forecast_line, presence: true
  validates :value, presence: true
  validates :timestamp, presence: true, uniqueness: { scope: :forecast_line_id }
  validates :from, presence: true
  validates :to, presence: true

  default_scope -> { order(from: :asc) }

  def to_flot
    [from.to_i * 1000, value]
  end
end

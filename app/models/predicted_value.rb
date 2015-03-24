class PredictedValue < ActiveRecord::Base
  belongs_to :forecast_line

  validates :forecast_line, presence: true
  validates :value, presence: true
  validates :from, presence: true
  validates :to, presence: true

  def self.csv_header
    CSV::Row.new([:from, :to, :predicted, :value], ['From', 'To', 'Predicted', 'Value'], true)
  end

  def to_csv_row
    CSV::Row.new([:from, :to, :predicted, :value], [from, to, predicted, value])
  end

  def to_flot
    [from.to_i * 1000, value]
  end
end

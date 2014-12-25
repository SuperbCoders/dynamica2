class ForecastLine < ActiveRecord::Base
  belongs_to :forecast
  belongs_to :item

  has_many :predicted_values, dependent: :destroy

  validates :forecast, presence: true
  validates :item, presence: true, unless: :summary?
  validates :item_id, uniqueness: { scope: :forecast_id }, unless: :summary?

  delegate :period, :depth, :from, :to, :group_method, to: :forecast

  def calculator
    from = forecast.from || item.values.order(timestamp: :asc).limit(1).pluck(:timestamp).first
    to = forecast.to || item.values.order(timestamp: :desc).limit(1).pluck(:timestamp).first
    Stats::Forecast.new(item, period: period, depth: depth, from: from, to: to, group_method: group_method)
  end

  def calculate
    calculated_values = calculator.calculate
    original_values = calculator.series_with_timestamps
    original_values.each do |key, value|
      predicted_values.create!(timestamp: key[:timestamp], from: key[:from], to: key[:to], value: value, predicted: false)
    end
    calculated_values.each do |key, value|
      predicted_values.create!(timestamp: key[:timestamp], from: key[:from], to: key[:to], value: value, predicted: true)
    end
  end
end

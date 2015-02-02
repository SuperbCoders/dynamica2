class Forecast < ActiveRecord::Base
  include Workflow

  PERIODS = %w(day month)
  GROUP_METHODS = %w(sum average)

  belongs_to :project

  has_many :forecast_lines, dependent: :destroy
  has_many :predicted_values, through: :forecast_lines

  validates :project, presence: true
  validates :period, presence: true, inclusion: { in: PERIODS }
  validates :group_method, presence: true, inclusion: { in: GROUP_METHODS }
  validates :depth, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :planned_at, presence: true

  before_validation :set_default_values

  self.skip_time_zone_conversion_for_attributes = [:from, :to]

  workflow do
    state :planned do
      event :forced_start, transitions_to: :pending
      event :start, transitions_to: :started
    end
    state :pending do
      event :start, transitions_to: :started
    end
    state :started do
      on_entry do
        calculate
      end
      event :finish, transitions_to: :finished
    end
    state :finished
  end

  def self.start_planned
    forecasts = Forecast.where(workflow_state: %w(planned)).where('planned_at <= ?', Time.now)
    forecasts.find_each(batch_size: 10) do |forecast|
      forecast.start!
    end
  end

  private

    def start
      setup_forecast_lines
      self.started_at = Time.now
      save!
    end

    def finish
      self.finished_at = Time.now
      save!
    end

    def calculate
      forecast_lines.find_each(batch_size: 10) do |forecast|
        forecast.calculate
      end
      calculate_summary if project.items.count > 1
      finish!
    end

    def calculate_summary
      summary = forecast_lines.create!(summary: true)
      predicted_values.group(:timestamp).sum(:value).each do |timestamp, value|
        same_value = predicted_values.find_by(timestamp: timestamp)
        summary.predicted_values.create!(timestamp: timestamp, from: same_value.from, to: same_value.to, value: value, predicted: same_value.predicted?)
      end
    end

    def set_default_values
      self.planned_at = Time.now
      self.group_method ||= 'sum'
      self.depth ||= case period
      when 'day' then 14
      when 'month' then 2
      else nil
      end
    end

    def setup_forecast_lines
      project.items.each do |item|
        forecast_lines.create(item: item)
      end
    end
end

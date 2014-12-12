class Forecast < ActiveRecord::Base
  include Workflow

  PERIODS = %w(day week month)
  GROUP_METHODS = %w(sum average)

  belongs_to :item

  has_many :predicted_values, dependent: :destroy

  validates :item, presence: true
  validates :period, presence: true, inclusion: { in: PERIODS }
  validates :group_method, presence: true, inclusion: { in: GROUP_METHODS }
  validates :depth, numericality: { only_integer: true, greater_than: 0 }
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
    @forecasts = Forecast.where(workflow_state: %w(planned)).where('planned_at <= ?', Time.now)
    @forecasts.find_each(batch_size: 10) do |forecast|
      forecast.start!
    end
  end

  def calculator
    Stats::Forecast.new(item, period: period, depth: depth, from: from, to: to, group_method: group_method)
  end

  private

    def start
      self.started_at = Time.now
      save!
    end

    def finish
      self.finished_at = Time.now
      save!
    end

    def calculate
      calculator.calculate.each do |timestamp, value|
        predicted_values.where(timestamp: timestamp).first_or_initialize(value: value).save!
      end
      finish!
    end

    def set_default_values
      self.from ||= item.values.order(timestamp: :asc).limit(1).pluck(:timestamp).first
      self.to ||= item.values.order(timestamp: :desc).limit(1).pluck(:timestamp).first
    end
end

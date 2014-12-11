class Item < ActiveRecord::Base
  belongs_to :project

  has_many :values, dependent: :destroy
  has_many :forecasts, dependent: :destroy

  validates :project, presence: true
  validates :sku, presence: true, uniqueness: { scope: :project_id }
  validates :name, presence: true

  before_validation :set_default_values

  private

    def set_default_values
      self.name ||= sku
    end
end

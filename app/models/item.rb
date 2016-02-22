# == Schema Information
#
# Table name: items
#
#  id           :integer          not null, primary key
#  project_id   :integer
#  sku          :string(255)
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  values_count :integer          default(0)
#  attachment   :string(255)
#

class Item < ActiveRecord::Base
  # @return [Boolean] whether there were errors while data parsing
  attr_accessor :with_parsing_errors
  attr_accessor :reload_attachment

  mount_uploader :attachment, FileUploader

  belongs_to :project

  has_many :values, dependent: :destroy
  has_many :forecast_lines, dependent: :destroy

  validates :project, presence: true
  validates :sku, presence: true, uniqueness: { scope: :project_id }

  before_validation :set_default_values
  after_save :load_values_from_attachment, if: :reload_attachment

  def attachment=(value)
    self.reload_attachment = true
    super
  end

  def display_name
    [name, sku, id].select(&:present?).first
  end

  private

    def self.generate_sku
      loop do
        sku = "product-#{SecureRandom.hex(8)}"
        break sku unless self.exists?(sku: sku)
      end
    end

    def set_default_values
      self.sku ||= self.class.generate_sku
    end

    def load_values_from_attachment
      return true unless attachment.present?
      parser = Attachment.new(self, "#{Rails.root}/public/#{attachment.url}")
      parser.process
      self.with_parsing_errors = parser.with_parsing_errors
      reload
      true
    end
end

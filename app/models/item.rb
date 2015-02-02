class Item < ActiveRecord::Base
  # @retirm [Boolean] whether item could not be created without an attachment
  attr_accessor :validate_attachment
  # @return [Integer] identifier of attachment that should be converted to values
  attr_accessor :attachment_id
  # @return [Boolean] whether there were errors while data parsing
  attr_accessor :with_parsing_errors

  belongs_to :project

  has_many :values, dependent: :destroy
  has_many :forecast_lines, dependent: :destroy

  validates :project, presence: true
  validates :sku, presence: true, uniqueness: { scope: :project_id }
  validates :name, presence: true
  validates :attachment_id, presence: true, if: :validate_attachment

  before_validation :set_default_values
  after_save :load_values_from_attachment, if: :attachment

  private

    def self.generate_sku
      loop do
        sku = SecureRandom.hex(32)
        break sku unless self.exists?(sku: sku)
      end
    end

    def set_default_values
      self.sku ||= self.class.generate_sku
      self.name ||= sku
    end

    def load_values_from_attachment
      @attachment.data.each do |timestamp, value|
        values.create(timestamp: timestamp, value: value)
      end
      self.with_parsing_errors = @attachment.with_parsing_errors
      @attachment.destroy
      true
    end

    def attachment
      @attachment ||= project.attachments.find_by(id: attachment_id) if attachment_id
    end
end

class Project < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: :slugged

  # @return [User] who created this project
  belongs_to :user

  has_many :permissions, dependent: :destroy
  has_many :pending_permissions, dependent: :destroy
  has_many :users, through: :permissions

  has_many :items, dependent: :destroy
  has_many :forecasts, dependent: :destroy

  validates :user, presence: true
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[-_A-Za-z0-9]+\z/ }

  before_validation :set_default_values

  private

    def self.generate_unique_slug
      loop do
        slug = SecureRandom.hex(16)
        break slug unless self.exists?(slug: slug)
      end
    end

    def set_default_values
      if slug.blank?
        derived_slug = name.to_s.parameterize
        self.slug = Project.exists?(slug: derived_slug) ? Project.generate_unique_slug : derived_slug
      end
    end
end

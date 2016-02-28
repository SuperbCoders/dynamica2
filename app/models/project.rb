# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  slug        :string(255)
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#  api_used    :boolean          default(FALSE)
#  demo        :boolean          default(FALSE)
#  guest_token :string(255)
#

class Project < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug, use: :slugged

  TIME_PERIOD = 1.year

  # @return [User] who created this project
  belongs_to :user

  has_many :permissions, dependent: :destroy
  has_many :pending_permissions, dependent: :destroy
  has_many :users, through: :permissions

  has_many :items, dependent: :destroy
  has_many :forecasts, dependent: :destroy

  has_many :logs, dependent: :destroy

  has_many :project_characteristics, dependent: :destroy
  has_many :products, dependent: :destroy

  has_one :shopify_integration, dependent: :destroy, class_name: 'ThirdParty::Shopify::Integration'
  has_one :integration, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[-_A-Za-z0-9]+\z/ }

  before_validation :set_default_values

  scope :actives, -> { where.not(user_id: nil) }

  # Marks project as a project that uses API
  def api_used!
    update_column(:api_used, true) unless api_used?
  end

  def recent_forecast
    forecasts.order(created_at: :asc, finished_at: :asc).last
  end

  # @return [Boolean] whether this project is integrated with Shopify
  def shopify?
    shopify_integration.present?
  end

  def set_project_owner!(user, session = {})
    return if user_id

    if user
      update_attributes user_id: user.id, guest_token: nil
      user.permissions.create! project: self, all: true
      session[:guest_token] = nil
    else
      update_attribute :guest_token, SecureRandom.hex(32)
      session[:guest_token] = guest_token
    end
  end

  def fetch_data(time_period = Project::TIME_PERIOD)
    CharacteristicsFetcherWorker.perform_async self.id, Time.now - time_period, Time.now
  end

  private

    def self.generate_unique_slug
      loop do
        slug = SecureRandom.hex(16)
        break slug unless self.exists?(slug: slug)
      end
    end

    def self.generate_unique_slug_by_name(name)
      derived_slug = name.to_s.parameterize
      if derived_slug.present? &&
        !friendly_id_config.reserved_words.include?(derived_slug) &&
        !Project.exists?(slug: derived_slug)
        derived_slug
      else
        Project.generate_unique_slug
      end
    end

    def set_default_values
      if slug.blank?
        self.slug = Project.generate_unique_slug_by_name(name)
      end
    end
end

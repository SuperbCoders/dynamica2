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
  include Alertable

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

  has_many :product_characteristics, dependent: :destroy
  has_many :products, dependent: :destroy

  has_one :shopify_integration, dependent: :destroy, class_name: 'ThirdParty::Shopify::Integration'
  has_one :integration, dependent: :destroy

  has_one :subscription, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[-_A-Za-z0-9]+\z/ }

  before_validation :set_default_values
  after_create :set_trial_subscription

  scope :actives, -> { where.not(user_id: nil) }

  # @return [Array] of top 5 seller products
  def top_5_products
    @top = {}
    @products = {}
    @ids = []

    # Retrieve grouped by product_id chars with summed gross_revenue
    p_chars = product_characteristics.group(:id, :product_id).sum(:gross_revenue)
    p_chars.keys.each do |pkey|
      @top[pkey[1]] ||= 0
      @top[pkey[1]] += p_chars[pkey]
    end

    # Sort by gross_revenue and reversed
    @top.sort_by(&:last).reverse[0..3].map { |p_info|
      p = products.find_by(id: p_info[0])
      if p
        @products[p.id] ||= { revenue: 0, title: 0, sales: 0 }
        @products[p.id][:revenue] = p_info[1]
        @products[p.id][:title] = p.title
        @products[p.id][:sales] = product_characteristics.where(product: p).sum(:sold_quantity)
      end
    }
    @products
  end

  def sub_type
    subscription.sub_type
  end

  def expired?
    subscription ? subscription.expired? : !set_trial_subscription
  end

  # Marks project as a project that uses API
  def api_used!
    update_column(:api_used, true) unless api_used?
  end

  def recent_forecast
    forecasts.order(created_at: :asc, finished_at: :asc).last
  end

  def shopify_session
    nil if not shopify?
    ShopifyAPI::Session.setup({:api_key => ENV['shopify_api_key'], :secret => ENV['shopify_secret']})
    session = ShopifyAPI::Session.new(self.shop_url, self.integration.access_token)
    ShopifyAPI::Base.activate_session(session)
    session
  end

  # @return [Boolean] whether this project is integrated with Shopify
  def shopify?
    integration.present?
  end

  def shopify_shop_name
    shop_url.split('.myshopify.com')[0]
  end

  def set_project_owner!(user, session = {})
    return if user_id

    if user && update_attributes(user_id: user.id, guest_token: nil)
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

  def parse_google_site_id
    unless google_site_id
      google_site_id = Dynamica::Google.parse_site_id("https://#{shop_url}")
      save
    end
  end

  # @return [DateTime] date of first project data for calendar filter
  # at frontend
  def first_project_data
    (project_characteristics.minimum('date').try(:to_datetime) || created_at.to_datetime)
  end

  # @return [DateTime] date of first product data for calendar filter
  # at frontend
  def first_product_data
    (product_characteristics.minimum('date').try(:to_datetime) || created_at.to_datetime)
  end

  private

    def set_trial_subscription
      subscription = Subscription.create_for(user, self)
      save
    end

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
        "#{derived_slug}-#{Project.generate_unique_slug[0..4]}"
      end
    end

    def set_default_values
      if slug.blank?
        self.slug = Project.generate_unique_slug_by_name(name)
      end
    end
end

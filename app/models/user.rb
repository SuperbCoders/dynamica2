# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  api_token              :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  avatar                 :string(255)
#  role                   :string(255)
#

class User < ActiveRecord::Base
  ROLES = %w(user admin)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar, AvatarUploader

  has_many :user_omnis, dependent: :destroy
  has_many :permissions, dependent: :restrict_with_error
  has_many :projects, through: :permissions
  has_many :logs, dependent: :destroy

  # @return [Array<Project>] project that were created by the user
  has_many :own_projects, class_name: 'Project', dependent: :restrict_with_error

  # Subscription
  has_one :subscription
  has_many :subscription_logs
  validates :api_token, uniqueness: true, if: :api_token
  validates :role, presence: true, inclusion: { in: ROLES }


  # Callbacks
  before_validation :set_default_values
  before_create :set_api_token

  after_create :create_subscription
  # after_create :send_welcome_mail

  # @return [Boolean] true if facebook omniauth exist
  def facebook?
    user_omnis.where('fb_id is not NULL').any?
  end

  def google?
    user_omnis.where('google_id is not NULL').any?
  end

  # @return [String] user name to use in views
  def display_name
    [name, email, id].select(&:present?).first
  end

  # return true if user is temporary
  # from Shopify omniauth
  # @return [Boolean]
  def temporary_user?
    (email && email.include?(Dynamica::TEMPORARY_MAIL_PREFIX))
  end

  # Class methods

  # Return initialize temporary User
  # @return [User]
  def self.build_temporary_user
    new(email: generate_random_email, password: generate_random_password)
  end

  # Return User from db if exists? or build new
  # @return [User]
  def self.build_from_omni(auth)
    exists?(email: auth.info.email) ? User.find_by_email(auth.info.email) : new(email: auth.info.email, password: generate_random_password, name: auth.info.name)
  end

  if Rails.env.development?
    def self.demo_user
      new(email: Faker::Internet.safe_email, password: SecureRandom.hex.to_s)
    end
  end

  def send_sub_changed_mail
    UserMailer.sub_changed(self.id).deliver
  end

  private

    # Create trail subscription for new user
    def send_welcome_mail
      UserMailer.welcome(self.id).deliver
    end

    def create_subscription
      Subscription.create(user: self) unless subscription
    end

    # Generates random email for temporary user
    # @return [String] random unique email that not exist in db
    def self.generate_random_email
      begin
        @email = [generate_random_password, '@', Dynamica::TEMPORARY_MAIL_PREFIX].join
      end while User.find_by_email(@email)
      @email
    end

    # Generates random password for temporary user
    # @return [String] random password
    def self.generate_random_password(length = 8)
      SecureRandom.hex.to_s[0..length]
    end

    # Generates unique API token
    # @return [String] unique API token
    def self.generate_api_token
      loop do
        token = SecureRandom.hex(32)
        break token unless self.exists?(api_token: token)
      end
    end

    # Sets API token to the user
    # @return [String] generated token
    def set_api_token
      self.api_token ||= self.class.generate_api_token
    end

    def set_default_values
      self.role ||= 'user'
    end

end

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
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar, AvatarUploader

  has_many :permissions, dependent: :restrict_with_error
  has_many :projects, through: :permissions

  # @return [Array<Project>] project that were created by the user
  has_many :own_projects, class_name: 'Project', dependent: :restrict_with_error

  has_many :logs, dependent: :destroy

  validates :api_token, uniqueness: true, if: :api_token
  validates :role, presence: true, inclusion: { in: ROLES }

  before_validation :set_default_values
  before_create :set_api_token

  # @return [String] user name to use in views
  def display_name
    [name, email, id].select(&:present?).first
  end

  private

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

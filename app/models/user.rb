class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :permissions, dependent: :restrict_with_error
  has_many :projects, through: :permissions

  # @return [Array<Project>] project that were created by the user
  has_many :own_projects, class_name: 'Project', dependent: :restrict_with_error

  validates :api_token, uniqueness: true, if: :api_token

  before_create :set_api_token

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

end

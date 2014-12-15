class PendingPermission < ActiveRecord::Base
  include PermissionBase

  validates :project, presence: true
  validates :email, presence: true, uniqueness: { scope: :project_id }
  validates :token, presence: true, uniqueness: true

  before_validation :set_token

  private

    # Generates unique token
    # @return [String] unique token
    def self.generate_token
      loop do
        token = SecureRandom.hex(32)
        break token unless self.exists?(token: token)
      end
    end

    # Sets token to the permission
    # @return [String] generated token
    def set_token
      self.token ||= self.class.generate_token
    end
end

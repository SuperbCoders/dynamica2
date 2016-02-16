# == Schema Information
#
# Table name: pending_permissions
#
#  id          :integer          not null, primary key
#  email       :string(255)
#  project_id  :integer
#  manage      :boolean
#  forecasting :boolean
#  read        :boolean
#  api         :boolean
#  token       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class PendingPermission < ActiveRecord::Base
  include PermissionBase

  validates :project, presence: true
  validates :email, presence: true, uniqueness: { scope: :project_id }
  validates :token, presence: true, uniqueness: true
  validate :validate_existing_permissions

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

    # Validate that there are no permissions for the chosen email address
    def validate_existing_permissions
      errors.add(:email, :taken) if project.permissions.joins(:user).exists?(users: { email: email })
    end
end

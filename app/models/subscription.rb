class Subscription < ActiveRecord::Base
  belongs_to :user

  enum sub_type: Dynamica::Billing::SUBSCRIPTION_TYPES

  scope :expired, -> { where('expire_at < ?', DateTime.now) }

  before_create :set_default_values
  validates :user, presence: true, uniqueness: true

  def renew!
    case sub_type
      when 'monthly' then period = Dynamica::Billing::MONTHLY_PERIOD
      when 'yearly' then period = Dynamica::Billing::YEARLY_PERIOD
    end

    update_attributes(expire_at: DateTime.now + period)
  end

  def type
    sub_type
  end

  def expired?
    expire_at < DateTime.now
  end

  private

  def set_default_values
    self.expire_at = DateTime.now + Dynamica::Billing::TRIAL_DAYS
    self.sub_type = :trial
  end
end

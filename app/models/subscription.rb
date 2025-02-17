class Subscription < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  enum sub_type: Dynamica::Billing::SUBSCRIPTION_TYPES

  before_create :set_trial_end_date
  validates :project, uniqueness: { scope: :user }

  scope :expired, -> { where('expire_at < ?', DateTime.now) }

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

  def self.create_for(user, project)
    create(user: user, project: project)
  end

  private

  def set_trial_end_date
    self.expire_at = DateTime.now + Dynamica::Billing::TRIAL_DAYS until self.expire_at
  end
end

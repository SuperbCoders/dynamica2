class SubscriptionLog < ActiveRecord::Base
  belongs_to :user

  before_create :set_default_values



  private


  def set_default_values
    self.date = DateTime.now
    self.status = 'pending'
  end

end

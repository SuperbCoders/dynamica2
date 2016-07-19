class SubscriptionLog < ActiveRecord::Base
  belongs_to :user

  before_create :set_default_values

  def table_description
  	self.description[/(?<=to )\w+/].capitalize + " plan"
  end

  def table_status
  	self.status == 'active' ? "Paid" : "Fail"
  end

  def billed
  	self.description[/(?<=to )\w+/] == "monthly" ? "$5" : "$49"
  end

  private


  def set_default_values
    self.date = DateTime.now
    self.status = 'pending'
  end

end

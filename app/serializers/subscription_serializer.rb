class SubscriptionSerializer < BaseSerializer
  attributes :sub_type, :expire_at, :expired?, :expired

  def expired
    object.try(:expired?)
  end
end

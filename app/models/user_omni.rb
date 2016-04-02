class UserOmni < ActiveRecord::Base
  belongs_to :user

  # @return [UserOmni] related to auth data
  def self.find_user(auth)
    case auth.provider
      when 'google_oauth2'
        find_by_google_id(auth.uid)
      when 'facebook'
        find_by_fb_id(auth.uid)
      when 'twitter'
        find_by_twitter_id(auth.uid)
      else
        nil
    end
  end
end

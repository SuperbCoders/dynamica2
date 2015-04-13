module Dynamica
  module Settings
    class Shopify < Settingslogic
      source "#{Rails.root}/config/shopify.yml"
      namespace Rails.env
    end
  end
end

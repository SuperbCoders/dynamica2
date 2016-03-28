module Alertable
  extend ActiveSupport::Concern

  included do
    attr_accessor :messages

    after_save    { add_message("#{self.class.name} - #{I18n.t('concerns.alertable.succefull_updated')}") }

    def add_message(message)
      if self.valid?
        self.messages ||= []
        self.messages << message if not self.messages.include? message
      end
    end

  end


end

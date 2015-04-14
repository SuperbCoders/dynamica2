class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  def default_url_options(options = {})
    { locale: I18n.locale }.merge(options)
  end

  def current_city_name
    @current_city_name ||= request.headers['X-GEO-CITY'] || 'Moscow'
  end

  def current_country_code
    @current_city_name ||= request.headers['X-GEO-COUNTRYCODE'] || 'RU'
  end

  def locale_by_current_country_code
    current_country_code == 'RU' ? 'ru' : 'en'
  end

  protected

    def set_locale
      I18n.locale = params[:locale] || locale_by_current_country_code
    end
end

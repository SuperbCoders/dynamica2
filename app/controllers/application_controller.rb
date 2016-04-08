class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action { @response = {success: false, messages: [], errors: []} }

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

  def after_sign_in_path_for(resource_or_scope)
    # Assign the project and current_user
    if session[:guest_token]
      project = Project.where(guest_token: session[:guest_token]).first
      project.try :set_project_owner!, current_user, session
    end

    dashboard_url
  end

  def serialize_resources(resources, serializer)
    return [{}] if not resources
    ActiveModel::SerializableResource.new(
        resources,
        each_serializer: serializer,
        scope: current_user,
        root: false
    ).serializable_hash
  end

  def serialize_resource(resource, serializer)
    return {} if not resource
    ActiveModel::SerializableResource.new(
        resource,
        serializer: serializer,
        scope: current_user,
        root: false
    ).serializable_hash
  end

  def templates
    if Rails.env == 'development'
      render '/templates/' + params[:url], layout: false
    else
      begin
        render '/templates/' + params[:url], layout: false
      rescue Exception => e
        render nothing: true, layout: false
      end
    end
  end

  protected

    def set_locale
      I18n.locale = params[:locale] || locale_by_current_country_code
    end
end

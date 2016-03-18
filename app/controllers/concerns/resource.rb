module Concerns::Resource
  extend ActiveSupport::Concern

  included do
  end

  def log_params
    logger.info "\n"*3
    logger.info "#{resource_symbol} params -> #{params.to_json}"
    logger.info "#{resource_symbol} resource_params -> #{resource_params}"
    logger.info "\n"*3
  end

  # Configuration
  def resource_scope
    #Some::Class
  end

  def resource_serializer

  end

  def permitted_params
  end

  def find_by_ids
    @resources = resource_scope.find(params[:ids])
  end

  def added_params
    {}
  end

  def resource_attribute_kind
    :id
  end

  def resource_attribute_params
    params[:id]
  end

  # Methods
  def new_resource
    @resource ||= resource_scope.new resource_params
  end

  def resource_symbol
    resource_scope.name.underscore.to_sym
  end

  def find_resource
    @resource ||= resource_scope.find_by(resource_attribute_kind => resource_attribute_params)
  end

  def find_resources
    @resources ||= search_proxy
  end

  def search_proxy
    resource_scope.all
  end

  def resource_params
    if params[resource_symbol] && permitted_params
      params.require(resource_symbol).permit(permitted_params).merge(added_params)
    elsif params[resource_symbol] && permitted_params.nil?
      params.require(resource_symbol).permit!.merge(added_params)
    else
      added_params
    end
  end

  # Actions
  def send_response(response)
    render json: response, status: response[:success] ? 200 : 403
  end

  def send_json(obj, success)
    render json: obj, status: success ? 200 : 403
  end

  def index
    send_json serialize_resources(@resources, resource_serializer ), true
  end

  def create
    send_json @resource, @resource.save
  end

  def update
    result = @resource.update_attributes(resource_params) if @resource
    send_json serialize_resource(@resource, resource_serializer),result
  end

  def new
    send_json @resource, true
  end

  def show
    if @resources
      res = serialize_resources(@resources, resource_serializer)
    elsif @resource
      res = serialize_resource(@resource, resource_serializer)
    end
    send_json res, true
  end

  def destroy
    send_json @resource, @resource.destroy
  end
end

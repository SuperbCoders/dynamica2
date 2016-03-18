class BaseSerializer < ActiveModel::Serializer
  attributes :id, :errors, :valid, :messages

  def serialize_resources(resources, serializer)
    ActiveModel::SerializableResource.new(
        resources,
        each_serializer: serializer,
        root: false
    ).serializable_hash
  end

  def serialize_resource(resource, serializer)
    ActiveModel::SerializableResource.new(
        resource,
        serializer: serializer,
        root: false
    ).serializable_hash
  end

  def messages
    object.try(:messages)
  end

  def valid
    object.valid?
  end

  def errors
    object.try(:errors).try(:full_messages)
  end

  def id
    object.id.to_s
  end
end

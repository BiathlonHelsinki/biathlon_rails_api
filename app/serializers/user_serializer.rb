class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :username,  :created_at, :updated_at, :slug

  
  def created_at
    object.created_at.in_time_zone.iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.in_time_zone.iso8601 if object.created_at
  end
  
end

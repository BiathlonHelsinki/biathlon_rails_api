class UserSerializer < ActiveModel::Serializer
  attributes :slug, :id, :email, :name, :username,  :created_at, :updated_at, :latest_balance, :events_attended, :last_attended, :last_attended_at, :avatar

  
  def created_at
    object.created_at.in_time_zone.iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.in_time_zone.iso8601 if object.created_at
  end
  
end

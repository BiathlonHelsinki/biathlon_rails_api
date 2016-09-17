class InstanceSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_at, :end_at, :description, :cost_bb, :image

  
  def created_at
    object.created_at.in_time_zone.iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.in_time_zone.iso8601 if object.created_at
  end
  
end

class EventSerializer < ActiveModel::Serializer
  attributes :id,  :start_at, :end_at, :cost_bb, :description, :image

  def name
    name[0..40].gsub(/\s\w+\s*$/, '...')
  end
  
  def created_at
    object.created_at.in_time_zone.iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.in_time_zone.iso8601 if object.created_at
  end
  
end

class InstanceSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_at, :end_at, :description, :cost_bb, :image, :slug, :checked_in_so_far

  def start_at 
    object.start_at.localtime
  end
  
  def end_at
    object.end_at.blank? ? nil : object.end_at.localtime
  end
  
  def checked_in_so_far
    object.instances_users.where(visit_date: Time.current.to_date).size + object.onetimers.today(Time.current.to_date).size
  end
  
  def name
    object.name[0..40].gsub(/\s\w+\s*$/, '...')
  end
  
  def image
    object.image.blank? ? object.event.image : object.image
  end
  
  def created_at
    object.created_at.in_time_zone.iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.in_time_zone.iso8601 if object.created_at
  end
  
end

class InstanceSerializer 
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :start_at, :end_at, :description, :cost_bb, :image, :slug, :checked_in_so_far



end

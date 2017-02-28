class Node < ApplicationRecord
  extend FriendlyId
  friendly_id :name , :use => [ :slugged, :finders, :history]
end

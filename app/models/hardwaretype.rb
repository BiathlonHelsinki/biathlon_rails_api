class Hardwaretype < ApplicationRecord
  has_many :hardwares
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders ]
end

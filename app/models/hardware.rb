class Hardware < ApplicationRecord
  devise :rememberable
  belongs_to :hardwaretype
  acts_as_token_authenticatable
  extend FriendlyId
  friendly_id :name, use: [:slugged, :finders ]
end

class Rsvp < ApplicationRecord
  belongs_to :instance
  belongs_to :user
  validates_presence_of :instance_id, :user_id
end

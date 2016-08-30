class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :ethtransaction
  belongs_to :item, polymorphic: true
  belongs_to :onetimer
  
  validates_presence_of :user_id, :item_id
end

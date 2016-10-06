class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :ethtransaction
  belongs_to :item, polymorphic: true
  belongs_to :extra, polymorphic: true
  belongs_to :onetimer
  has_one :instances_user
  validates_presence_of :user_id, :item_id
end

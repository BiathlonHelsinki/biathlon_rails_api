class Roombooking < ApplicationRecord
  belongs_to :user
  belongs_to :booker, polymorphic: true
  belongs_to :ethtransaction
  belongs_to :rate, optional: true
  validates_presence_of :user_id, :points_needed
  
  has_many :activities, as: :item, dependent: :destroy, autosave: true
  
  scope :between, -> (start_time, end_time) { 
    where( [ "(day >= ?  AND  day <= ?)",  start_time, end_time ])
  }
  
  
  def create_activity_feed
    
  end
  
  
end

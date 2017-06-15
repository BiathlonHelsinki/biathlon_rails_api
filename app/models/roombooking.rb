class Roombooking < ApplicationRecord
  belongs_to :user
  belongs_to :ethtransaction
  belongs_to :rate
  validates_presence_of :user_id, :rate_id, :day
  has_many :activities, as: :item, dependent: :destroy, autosave: true
  
  scope :between, -> (start_time, end_time) { 
    where( [ "(day >= ?  AND  day <= ?)",  start_time, end_time ])
  }
  
  
  def create_activity_feed
    
  end
  
  
end

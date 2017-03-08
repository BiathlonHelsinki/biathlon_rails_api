class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :instance
  
  validates_presence_of :user_id, :instance_id
  
  scope :by_event, -> (instance) { where(:instance_id => instance)}
  scope :not_waiting, -> () { where("waiting_list is not true")}

  
end

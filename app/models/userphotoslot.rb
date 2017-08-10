class Userphotoslot < ApplicationRecord
  belongs_to :user
  belongs_to :userphoto
  belongs_to :ethtransaction
  belongs_to :activity
  
  
end

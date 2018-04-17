class Userphotoslot < ApplicationRecord
  belongs_to :user
  belongs_to :userphoto, optional: true
  belongs_to :ethtransaction, optional: true
  belongs_to :activity, optional: true
  
  
end

class InstancesUser < ApplicationRecord
  belongs_to :instance
  belongs_to :user
  

end

class InstancesUser < ApplicationRecord
  belongs_to :instance
  belongs_to :user
  belongs_to :activity
  validates_presence_of :instance_id, :activity_id, :user_id, :visit_date

end

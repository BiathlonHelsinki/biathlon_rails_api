class Pledge < ApplicationRecord
  belongs_to :item, polymorphic: true
  belongs_to :user
  validates_presence_of :user_id, :pledge
  validates_numericality_of :pledge, greater_than_or_equal_to: 0
  belongs_to :instance
  scope :unconverted, -> () { where('converted = 0 OR converted is null')}
  scope :converted, -> () { where(converted: true)}
end

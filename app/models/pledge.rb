class Pledge < ApplicationRecord
  belongs_to :item, polymorphic: true, touch: true
  belongs_to :pledger, polymorphic: true
  belongs_to :blockchaintransaction, optional: true
  has_many :activities, as: :item
  acts_as_paranoid
  belongs_to :user
  validates_presence_of :user_id, :pledge
  validates_numericality_of :pledge, greater_than_or_equal_to: 0
  belongs_to :instance
  scope :unconverted, -> () { where('converted = 0 OR converted is null')}
  scope :converted, -> () { where(converted: true)}
end

class Proposal < ApplicationRecord
  belongs_to :user
  has_many :images, as: :item, :dependent => :destroy
  has_many :pledges, as: :item, :dependent => :destroy
  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :pledges
  validates_presence_of :user_id, :name
  has_many :comments, as: :item, :dependent => :destroy
  has_many :instances
  belongs_to :proposalstatus
  has_many :activities, as: :item, dependent: :destroy
  def self.schedulable
    all.to_a.delete_if{|x| x.pledged < Rate.get_current.experiment_cost }
  end
  
  def has_enough?
    pledged >= Rate.get_current.experiment_cost
  end
  
  
  def pledged
    pledges.sum(&:pledge)
  end
  
  def discussion
    [pledges, comments].flatten.compact
  end
  
end

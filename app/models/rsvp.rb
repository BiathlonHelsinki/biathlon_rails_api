class Rsvp < ApplicationRecord
  belongs_to :instance, optional: true
  belongs_to :user
  belongs_to :meeting, optional: true
  validates_presence_of  :user_id
  belongs_to :blockchain_transaction, optional: true
  has_one :ethtransaction, through: :blockchain_transaction
  validate :check_user_points, on: :create
  validate :not_open_time, on: :create

  scope :pending, ->() { where(["instance_id > ? and blockchain_transaction_id is null", 257]) }

  def check_user_points
    user.can_rsvp?
  end

  def not_open_time
    !instance.open_time
  end


end

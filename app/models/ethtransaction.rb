class Ethtransaction < ApplicationRecord
  belongs_to :transaction_type
  has_one :activity
  validates_presence_of :transaction_type_id
end

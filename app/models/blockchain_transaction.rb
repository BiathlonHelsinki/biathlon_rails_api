class BlockchainTransaction < ApplicationRecord
  belongs_to :transactiontype
  belongs_to :account
  belongs_to :ethtransaction
  belongs_to :activity
end

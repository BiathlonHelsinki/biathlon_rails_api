class AddRecipientaccountIdToBlockchainTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :blockchain_transactions, :recipient_id, :integer, foreign_key: true
  end
end

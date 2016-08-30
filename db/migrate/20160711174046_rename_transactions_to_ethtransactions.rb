class RenameTransactionsToEthtransactions < ActiveRecord::Migration[5.0]
  def self.up
    rename_table :transactions, :ethtransactions
    rename_column :activities, :transaction_id, :ethtransaction_id
  end 
  def self.down
    rename_table :ethtransactions, :transactions
    rename_column :activities, :ethtransaction_id, :transaction_id
  end
end

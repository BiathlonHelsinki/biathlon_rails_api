class CreateBlockchainTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :blockchain_transactions do |t|
      t.references :transaction_type, foreign_key: true
      t.references :account, foreign_key: true
      t.references :ethtransaction, foreign_key: true
      t.references :activity, foreign_key: true
      t.integer :value
      t.datetime :submitted_at
      t.datetime :confirmed_at
      t.timestamps
    end
  end
end

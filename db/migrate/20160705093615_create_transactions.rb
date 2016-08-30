class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.references :transaction_type, foreign_key: true, null: false
      t.string :txaddress, null: false, limit: 66
      t.string :source_account
      t.string :recipient_account
      t.integer :source_user
      t.integer :recipient_user
      t.integer :value
      t.timestamp :timeof

      t.timestamps
    end
  end
end

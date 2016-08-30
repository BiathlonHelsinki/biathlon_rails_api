class CreateTransactionTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :transaction_types do |t|
      t.string :name
      t.string :slug, unique: true
      t.timestamps
    end
  end
  
  def data
    TransactionType.create(name: 'Create')
    TransactionType.create(name: 'Spend')
    TransactionType.create(name: 'Transfer')
  end
end

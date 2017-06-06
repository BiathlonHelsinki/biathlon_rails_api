class AddFactorialToTransactiontypes < ActiveRecord::Migration[5.0]
  def change
    add_column :transaction_types, :factorial, :integer, default: 0
    execute("update transaction_types set factorial = 1 where name ='Create'")
    execute("update transaction_types set factorial = -1 where name = 'Spend'")
    
  end
end

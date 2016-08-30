class AddExternalsToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :external, :boolean
    add_column :accounts, :primary_account, :boolean
    execute('update accounts set primary_account = true')
  end
end

class AddGethpwdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :geth_pwd, :string
  end
end

class AddLatestbalanceToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :latest_balance, :integer, null: false, default: 0
    add_column :users, :latest_balance_checked_at, :timestamp
  end
end

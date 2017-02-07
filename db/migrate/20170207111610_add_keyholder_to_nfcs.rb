class AddKeyholderToNfcs < ActiveRecord::Migration[5.0]
  def change
    add_column :nfcs, :keyholder, :boolean, default: false, null: false
  end
end

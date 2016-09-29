class AddConfirmedToEthtransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :ethtransactions, :confirmed, :boolean, null: false, default: false
  end
end

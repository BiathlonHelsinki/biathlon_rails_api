class AddTxaddressToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :txaddress, :string, length: 66
  end
end

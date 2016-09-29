class AddCheckedconfirmationatToEthtransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :ethtransactions, :checked_confirmation_at, :datetime
  end
end

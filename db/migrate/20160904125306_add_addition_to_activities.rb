class AddAdditionToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :addition, :integer, default: 0, null: false
  end
end

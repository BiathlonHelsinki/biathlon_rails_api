class AddOnetimerIdToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :onetimer_id, :integer
  end
end

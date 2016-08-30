class AddExtrainfoToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :extra_info, :string
  end
end

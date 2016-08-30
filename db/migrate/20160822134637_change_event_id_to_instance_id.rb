class ChangeEventIdToInstanceId < ActiveRecord::Migration[5.0]
  def change
    rename_column :onetimers, :event_id, :instance_id
  end
end

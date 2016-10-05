class AddActivityIdToInstancesUser < ActiveRecord::Migration[5.0]
  def change
    add_column :instances_users, :activity_id, :integer
    add_index :instances_users, :activity_id
    add_index :instances_users, [:user_id, :instance_id, :visit_date], :unique => true
  end
end

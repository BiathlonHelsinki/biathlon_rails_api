class CreateJoinTableInstancesUsers < ActiveRecord::Migration[5.0]
  def self.up
    create_join_table :instances, :users do |t|
      # t.index [:event_id, :user_id]
      # t.index [:user_id, :event_id]
    end
    execute "ALTER TABLE instances_users ADD UNIQUE (instance_id, user_id)"
    drop_table :events_users
  end
  
  def self.down
    drop_table :instances_users
  end
  
end

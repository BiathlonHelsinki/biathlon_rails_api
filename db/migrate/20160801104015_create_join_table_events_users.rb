class CreateJoinTableEventsUsers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :events, :users do |t|
      # t.index [:event_id, :user_id]
      # t.index [:user_id, :event_id]
    end
    execute "ALTER TABLE events_users ADD UNIQUE (event_id, user_id)"
  end
end

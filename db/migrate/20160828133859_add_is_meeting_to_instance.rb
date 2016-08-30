class AddIsMeetingToInstance < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :is_meeting, :boolean
  end
end

class AddRecurrenceToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :recurrence, :integer
    add_column :proposals, :intended_sessions, :integer
    add_column :proposals, :stopped, :boolean, null: false, default: false
  end
end

class AddScheduledToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :scheduled, :boolean
    add_column :proposals, :allow_rescheduling, :boolean
    add_column :instances, :proposal_id, :integer
    add_index :instances, :proposal_id
  end
end

class AddProposalstatusIdToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :proposalstatus_id, :integer, index: true
  end
end

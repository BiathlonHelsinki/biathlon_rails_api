class AddCachesToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :total_needed_with_recurrence_cached, :integer
    add_column :proposals, :needed_array_cached, :string
    add_column :proposals, :has_enough_cached, :boolean
    add_column :proposals, :number_that_can_be_scheduled_cached, :integer
    add_column :proposals, :pledgeable_cached, :boolean
    add_column :proposals, :pledged_cached, :integer
    add_column :proposals, :remaining_pledges_cached, :integer
    add_column :proposals, :spent_cached, :integer
    add_column :proposals, :published_instances, :integer, default: 0, null: false

    Proposal.find_each(&:save)
  end
end

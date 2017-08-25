class AddEventIdToProposals < ActiveRecord::Migration[5.0]
  def self.up
    # add_column :proposals, :event_id, :integer
    Proposal.all.each do |p|
      next if p.instances.empty?
      exp = p.instances.first.event
      exp.update_attribute(:proposal_id, p.id)
      # p.update_attribute(:event_id, p.instances.first.event.id)
    end
    Pledge.unconverted.each do |p|
      next if p.item.class == Event
      next if p.item.still_proposal?
      # next if p.item.event.nil?

      p.item = p.item.event
      p.save
    end
  end
  
  def self.down
    remove_column :proposals, :event_id
  end
end

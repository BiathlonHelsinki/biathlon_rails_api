class AddNotifiedToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :notified, :boolean
  end
end

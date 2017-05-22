class AddRequireallToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :require_all, :boolean, null: false, default: false
  end
end

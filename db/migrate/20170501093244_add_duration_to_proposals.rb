class AddDurationToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :duration, :integer, default: 1
    add_column :proposals, :is_month_long, :boolean, null: false, default: false
  end
end

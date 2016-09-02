class AddDeletedAtToPledges < ActiveRecord::Migration[5.0]
  def change
    add_column :pledges, :deleted_at, :datetime
  end
end

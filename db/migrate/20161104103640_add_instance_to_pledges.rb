class AddInstanceToPledges < ActiveRecord::Migration[5.0]
  def change
    add_column :pledges, :instance_id, :integer
  end
end

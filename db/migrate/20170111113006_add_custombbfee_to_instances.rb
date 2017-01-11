class AddCustombbfeeToInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :custom_bb_fee, :float
  end
end

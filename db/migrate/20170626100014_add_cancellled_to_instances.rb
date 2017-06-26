class AddCancellledToInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :cancelled, :boolean, null: false, default: false
  end
end

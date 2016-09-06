class AddMultipleentryToInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :allow_multiple_entry, :boolean
  end
end

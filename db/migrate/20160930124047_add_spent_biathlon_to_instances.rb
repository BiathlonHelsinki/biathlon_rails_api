class AddSpentBiathlonToInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :spent_biathlon, :boolean, null: false, default: false
  end
end

class AddSequenceToInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :sequence, :string
  end
end

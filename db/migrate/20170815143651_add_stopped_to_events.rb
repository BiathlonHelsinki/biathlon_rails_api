class AddStoppedToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :stopped, :boolean
  end
end

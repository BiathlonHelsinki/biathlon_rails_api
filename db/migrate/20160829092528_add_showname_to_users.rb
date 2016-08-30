class AddShownameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :show_name, :boolean, null: false, default: false
  end
end

class AddCollapseinwebsiteToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :collapse_in_website, :boolean, null: false, default: false
  end
end

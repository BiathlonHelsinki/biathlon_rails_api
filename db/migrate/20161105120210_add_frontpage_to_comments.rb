class AddFrontpageToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :frontpage, :boolean, null: false, default: false
  end
end

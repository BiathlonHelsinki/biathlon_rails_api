class AddMoreToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :show_twitter_link, :boolean, null: false, default: false
    add_column :users, :show_facebook_link, :boolean, null: false, default: false
  end
end

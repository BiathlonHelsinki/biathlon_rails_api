class AddExtrasToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :opt_in, :boolean
    add_column :users, :website, :string
    add_column :users, :about_me, :text
    add_column :users, :twitter_name, :string
    add_column :users, :address, :string
    add_column :users, :postcode, :string
    add_column :users, :city, :string
    add_column :users, :country, :string
  end
end

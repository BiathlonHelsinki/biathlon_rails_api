class AddIdToInstancesUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :instances_users, :id, :primary_key
  end
end

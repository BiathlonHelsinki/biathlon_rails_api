class AddVisitdateToInstancesUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :instances_users, :visit_date, :date
    execute('alter table instances_users  drop constraint instances_users_instance_id_user_id_key')
  end
end

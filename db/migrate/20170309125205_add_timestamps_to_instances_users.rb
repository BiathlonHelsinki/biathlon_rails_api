class AddTimestampsToInstancesUsers < ActiveRecord::Migration[5.0]
  def self.up
    add_column :instances_users, :created_at, :datetime
    add_column :instances_users, :updated_at, :datetime
    InstancesUser.all.each do |iu|
      if iu.activity.nil?
        iu.update_attribute(:created_at, iu.visit_date.to_datetime)
        iu.update_attribute(:updated_at, iu.visit_date.to_datetime)
      else
        if iu.activity.onetimer.nil?
          iu.update_attribute(:created_at, iu.activity.created_at)
          iu.update_attribute(:updated_at, iu.activity.created_at)
        else
          iu.update_attribute(:updated_at, iu.activity.onetimer.updated_at)
          iu.update_attribute(:created_at, iu.activity.onetimer.updated_at)
        end
      end
    end
    change_column  :instances_users, :created_at, :datetime, null: false
    change_column  :instances_users, :updated_at, :datetime, null: false
  end
  
  def self.down
    remove_column :instances_users, :created_at
    remove_column :instances_users, :updated_at
  end
end

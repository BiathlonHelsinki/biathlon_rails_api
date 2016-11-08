class AddRequestRsvpToInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :request_rsvp, :boolean
    add_column :instances, :request_registration, :boolean
  end
end

class AddExtrarelationToActivities < ActiveRecord::Migration[5.0]
  def change
    add_reference :activities, :extra, polymorphic: true
  end
end

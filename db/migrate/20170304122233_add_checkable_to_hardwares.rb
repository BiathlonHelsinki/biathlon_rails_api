class AddCheckableToHardwares < ActiveRecord::Migration[5.0]
  def change
    add_column :hardwares, :checkable, :boolean
    add_column :hardwares, :last_checked_at, :datetime
    add_column :hardwares, :notified_of_error, :boolean
  end
end

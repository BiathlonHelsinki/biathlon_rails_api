class ChangeOptin < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:users, :opt_in, true)
  end
end

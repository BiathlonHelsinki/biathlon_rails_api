class AddSystemflagToComment < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :systemflag, :boolean, default: false, null: false
  end
end

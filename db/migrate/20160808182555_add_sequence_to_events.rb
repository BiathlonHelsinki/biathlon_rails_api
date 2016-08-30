class AddSequenceToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :sequence, :string
  end
end

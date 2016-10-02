class AddExtrainfoToPledges < ActiveRecord::Migration[5.0]
  def change
    add_column :pledges, :extra_info, :string
  end
end

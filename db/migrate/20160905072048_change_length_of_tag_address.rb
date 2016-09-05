class ChangeLengthOfTagAddress < ActiveRecord::Migration[5.0]
  def self.up
    change_column :nfcs, :tag_address, :string, :limit => 20
  end

  def self.down
    change_column :nfcs, :tag_address, :string, :limit => 16
  end

end

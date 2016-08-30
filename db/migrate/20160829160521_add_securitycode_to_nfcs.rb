class AddSecuritycodeToNfcs < ActiveRecord::Migration[5.0]
  def change
    add_column :nfcs, :security_code, :string
    add_column :nfcs, :last_used, :datetime
  end
end

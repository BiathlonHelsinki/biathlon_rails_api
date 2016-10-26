class AddSentnumberToEmails < ActiveRecord::Migration[5.0]
  def change
    add_column :emails, :sent_number, :integer
  end
end

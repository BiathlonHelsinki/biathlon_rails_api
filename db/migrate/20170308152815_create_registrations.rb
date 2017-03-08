class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.references :user, foreign_key: true
      t.references :instance, foreign_key: true
      t.string :phone
      t.text :question1
      t.text :question2
      t.boolean :boolean1
      t.boolean :boolean2
      t.text :question3
      t.text :question4
      t.boolean :approved
      t.boolean :waiting_list, null: false, default: false

      t.timestamps
    end
    add_column :instances, :email_registrations_to, :string
    add_column :instances, :question1_text, :string
    add_column :instances, :question2_text, :string
    add_column :instances, :question3_text, :string
    add_column :instances, :question4_text, :string
    add_column :instances, :boolean1_text, :string
    add_column :instances, :boolean2_text, :string    
    add_column :instances, :require_approval, :boolean
    add_column :instances, :hide_registrants, :boolean
    add_column :instances, :show_guests_to_public, :boolean
    add_column :instances, :max_attendees, :integer
    add_column :instances, :registration_open, :boolean, null: false, default: true
  end
end

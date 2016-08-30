class CreateProposals < ActiveRecord::Migration[5.0]
  def change
    create_table :proposals do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.text :short_description
      t.string :timeframe
      t.text :goals
      t.string :intended_participants

      t.timestamps
    end
    add_column :events, :proposal_id, :integer
  end
end

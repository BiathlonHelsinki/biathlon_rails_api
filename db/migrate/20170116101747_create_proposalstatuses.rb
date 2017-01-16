class CreateProposalstatuses < ActiveRecord::Migration[5.0]
  def self.up
    create_table :proposalstatuses do |t|
      t.string :slug

      t.timestamps
    end
    Proposalstatus.create_translation_table! name: :string
  end
  
  def self.down
    drop_table :proposalstatuses
    Proposalstatus.drop_translation_table! 
  end
end

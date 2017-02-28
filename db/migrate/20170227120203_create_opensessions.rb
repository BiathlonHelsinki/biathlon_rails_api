class CreateOpensessions < ActiveRecord::Migration[5.0]
  def self.up
    create_table :opensessions do |t|
      t.references :node, foreign_key: true, null: false
      t.datetime :opened_at
      t.datetime :closed_at

      t.timestamps
    end
    execute('CREATE UNIQUE INDEX null_valid_from ON opensessions(node_id) where closed_at IS NULL')
  end
  
  def self.down
    drop_table :opensessions
  end
end

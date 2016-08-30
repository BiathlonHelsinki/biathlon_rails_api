class CreateSettings < ActiveRecord::Migration[5.0]
  def self.up
    enable_extension "hstore"
    create_table :settings do |t|
      t.hstore :options

      t.timestamps
    end
  end
  
  def data
    s = Setting.create(options: {"network" => Figaro.env.network, "contract_address" => Figaro.env.contract_address, 'coinbase' => Figaro.env.coinbase, 'contract_abi' => Figaro.env.contract_abi, 'latest_block' => 0})

  end
  
  def self.down
    drop_table :settings    
     disable_extension "hstore"
  end
  
end

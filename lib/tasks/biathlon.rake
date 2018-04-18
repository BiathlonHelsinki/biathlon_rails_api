require 'json'

def get_feed(url = '')
  response = HTTParty.get(Figaro.env.dapp_address + url)
  return response.parsed_response
  
end

def account_balance(url = '/account_balance', account)
  response = HTTParty.post(Figaro.env.dapp_address + url, {account: account})
  return response.parsed_response
end

namespace :kuusi_palaa do
  desc 'check door controller'
  task check_door_controller: :environment do
    require 'net/http'
    require 'uri'
    Hardware.monitored.each do |hardware|
      if hardware.last_checked_at.utc <= 150.minutes.ago
        next if hardware.notified_of_error == true
        uri = URI.parse("https://textbelt.com/text")
        numbers = Figaro.env.emergency_contact.split(',')
        numbers.each do |number|
          Net::HTTP.post_form(uri, {
            :phone => number,
            :message => "Kuusi Palaa's #{hardware.name} has not been online since #{hardware.last_checked_at.localtime.to_s}, please check!",
            :key => Figaro.env.textbelt_key
          })

          hardware.update_attribute(:notified_of_error, true)
          

        end
      end
        
    end
  end
end


namespace :bidapp do


  desc 'Convert Temps to points from file'
  task convert_temps: :environment do
    file = File.read('/tmp/temps.json')
    data_hash = JSON.parse(file)['data']
    data_hash['accounts'].each do |account, values|
      points = values['biathlon'].to_i
      b = BlockchainTransaction.new(value: points, account: Account.find_by(address: account), 
                                     transaction_type: TransactionType.find_by(name: 'Create'))
      acc = Account.find_by(address: account)
      if acc.nil?
        puts 'no account for ' + account
        next
      end
      user = acc.user

      if user.nil?
        puts 'no user for ' + account
      else
        a = Activity.create(user: user, item_type: 'Post', item_id: 31, 
          addition: 1, ethtransaction: nil, description: 'migrated_temps_from_temporary', numerical_value: points,
           blockchain_transaction: b)
        if b.save
          BlockchainHandlerJob.set(wait: 1.minutes).perform_later b
        end  
        puts 'should populate ' + account + ' with ' + points.to_s + ' points'
      end
    end
  end
  
  desc 'Grab missing blockchain transactions'
  task submit_missing: :environment do
    BlockchainTransaction.where(["ethtransaction_id is null and created_at < ?", 4.hours.ago]).each do |b|
      b.update_column(:submitted_at, nil)
      BlockchainHandlerJob.perform_later b
    end
  end
      
  desc 'Confirm all unconfirmed Ethereum transactions'
  task confirm_all: :environment do
    api = BidappApi.new
    transactions = Ethtransaction.unconfirmed.order(id: :asc)
    transactions.each do |tx|
      # p 'checking ' + tx.txaddress  
      check = api.confirm(tx.txaddress)
      tx.update_column(:checked_confirmation_at,  Time.now)
      unless check == 'null'
        if JSON.parse(check)
          if JSON.parse(check)['status'] == '0x1'
            tx.update_column(:confirmed, true)
            # p 'confirmed on blockchain ' + tx.txaddress
          elsif check['status'] == '0x0'
            # p 'No confirmation for ' + tx.txaddress
          end
        end
      end
    end
  end
  
  
  desc 'Check all accounts under coinbase and synchronise with postgres'
  task sync_accounts: :environment do
    mainfeed = get_feed
    mainfeed['data']['accounts'].each do |acc|
      a = Account.where("external is not true").find_or_create_by(address: acc.first)
      a.update_column(:balance, acc.last['biathlon'].to_i) rescue 0

      next if a.holder.nil?
      a.holder.update_column(:latest_balance, a.balance) unless a.balance == a.holder.latest_balance

    end
    
    # check external accounts
    api = BidappApi.new
    externals = Account.external.each do |acc|
      api_data = api.get_balance(acc.address)
      acc.balance = api_data['success'].to_i rescue 0
      if acc.changed?
        acc.save
        next if acc.holder.nil?
        acc.holder.update_column(:latest_balance, acc.balance)

      end      
    end
  end
  
  # desc 'one-time audit after starting kp'
  # task kp_fix: :environment do
  #   api = BidappApi.new
  #   temps = JSON.parse(File.read("/Users/fail/temps.json"))
  #   had_temps = []
  #   temps["data"]["accounts"].each do |account|
  #     dbacc = Account.find_by(address: account.first)
  #     next if dbacc.nil?
  #     next if dbacc.holder.nil?
  #     holder = dbacc.holder
  #     had_temps.push(holder)
  #     if holder.stakes.paid.empty?
  #       puts "User " + holder.display_name + " should have " + account.last["biathlon"].to_s + " points"
  #     else
  #       should_have = (holder.stakes.paid.sum(&:amount) * 500) + account.last["biathlon"].to_i
  #       puts "STAKEHOLDER " + holder.display_name + " should have " + should_have.to_s + " points"
  #       # puts "   --  " + holder.stakes.paid.sum(&:amount).to_s + ' stakes and ' + account.last["biathlon"] + ' Temps'
  #       api_data = api.get_balance(holder.get_eth_address)
  #       puts "     -- actually has " + api_data['success']

  #       if (should_have.to_i - api_data['success'].to_i) > 0 
  #         puts "  should mint " + (should_have.to_i - api_data['success'].to_i).to_s
  #         # mint = api.mint(holder.get_eth_address, (should_have.to_i - api_data['success'].to_i))
  #         # sleep 40
  #       elsif (should_have.to_i - api_data['success'].to_i) < 0
  #         puts "  should spend " + ((should_have.to_i - api_data['success'].to_i) * -1).to_s
  #         # spend = api.spend(holder.get_eth_address, ( (should_have.to_i - api_data['success'].to_i) * -1) )
  #         # sleep 40
  #       end
  #     end
  #   end
  #   Stake.paid.each do |stake|
  #     next if had_temps.include?(stake.owner)
  #     should_have = (stake.owner.stakes.paid.sum(&:amount) * 500)
  #     had_temps.push(stake.owner)
  #     puts "STAKEHOLDER " + stake.owner.display_name + " should have " + should_have.to_s + " points from " + stake.owner.stakes.paid.sum(&:amount).to_s + ' stakes'
  #     api_data = api.get_balance(stake.owner.get_eth_address)
  #     puts "     -- actually has " + api_data['success']
  #     if (should_have.to_i - api_data['success'].to_i) > 0 
  #       puts "  should mint " + (should_have.to_i - api_data['success'].to_i).to_s
  #       # mint = api.mint(holder.get_eth_address, (should_have.to_i - api_data['success'].to_i))
  #       # sleep 40
  #     elsif (should_have.to_i - api_data['success'].to_i) < 0
  #       puts "  should spend " + ((should_have.to_i - api_data['success'].to_i) * -1).to_s
  #       # spend = api.spend(holder.get_eth_address, ( (should_have.to_i - api_data['success'].to_i) * -1) )
  #       # sleep 40
  #     end      
  #     puts " "
  #   end
  #   # had_temps.each do |stakeholder|
  #   #   if stakeholder.accounts.empty?
  #   #     puts 'no eth address for ' +  stakeholder.display_name
  #   #   else
  #   #     puts stakeholder.accounts.first.address
  #   #   end
  #   # end
  # end

  desc 'audit stake awards'
  task stake_transactions: :environment do
    api = BidappApi.new
    i = 0
    Stake.paid.map(&:owner).uniq.each do |user_or_group|
      next unless user_or_group.is_stakeholder?
      user_or_group.stakes.paid.each do |stake|
        if stake.ethtransaction_id.nil? && stake.blockchain_transaction.nil?
          unless stake.blockchain_transaction
            puts 'no transaction info for stake #' + stake.id.to_s
          end
        end
      end
    end

  end

  desc 'audit user accounts on blockchain'
  task audit_users: :environment  do
    api = BidappApi.new
    Account.all.each do |account|
      user = account.holder
      next if account.holder.nil?
      next if account.external == true
      unless user.all_activities.empty?
        total = 0
        plus = user.own_activities.kuusi_palaa.select{|x| x.addition == 1}.sum{|x| x.value.to_i}         
        minus =  user.own_activities.kuusi_palaa.select{|x| x.addition == -1}.sum{|x| x.value.to_i}
        plus2 = user.own_activities.kuusi_palaa.select{|x| x.description =~ /received_from/ && x.user == user && x.addition == 0 }.sum{|x| x.value.to_i}
        minus2 = user.own_activities.kuusi_palaa.select{|x| x.description =~ /received_from/ && x.item == user && x.addition == 0 }.sum{|x| x.value.to_i}
        total += plus
        total += plus2
        total -= minus
        total -= minus2
        if user.latest_balance != total
          p "User #{user.display_name} (id# #{user.id.to_s}: Balance is #{user.latest_balance.to_s}, should be #{total.to_s}"
          if user.latest_balance > total
            # too many, let's delete some
            p '  -- will delete ' + (user.latest_balance - total).to_s + ' from blockchain balance'
            begin
              b = BlockchainTransaction.new( value:  user.latest_balance - total, account: account, transaction_type: TransactionType.find_by(name: 'Spend'))
              a = Activity.create(user: user.class == Group ? user.members.first.user : user, contributor: user, item_type: 'Post', item_id: 36, ethtransaction_id: nil, 
                description: "had_their_blockchain_balance_adjusted_by", numerical_value: "-" + (user.latest_balance - total).to_s, 
                  addition: 0, blockchain_transaction: b)
              if b.save
                BlockchainHandlerJob.perform_later b              
                puts 'submitted blockchain job'
                sleep 4
                              
              else
                puts "error"
              end
            rescue Exception => e
              # don't write anything unless it goes to blockchain
              puts 'spending error' + e.inspect
            end  
          elsif user.latest_balance < total
            p '  -- will add ' + (total - user.latest_balance).to_s + ' from blockchain balance'
            begin
              b = BlockchainTransaction.new( value:  total - user.latest_balance , account: account, transaction_type: TransactionType.find_by(name: 'Create'))
              a = Activity.create(user: user.class == Group ? user.members.first.user : user, contributor: user, item_type: 'Post', item_id: 36, ethtransaction_id: nil, 
                description: "had_their_blockchain_balance_adjusted_by", numerical_value: (total - user.latest_balance ).to_s, 
                  addition: 0, blockchain_transaction: b)
              if b.save
                BlockchainHandlerJob.perform_later b              
                puts 'submitted blockchain job'
                sleep 4
                              
              else
                puts "error"
              end
             rescue Exception => e
              # don't write anything unless it goes to blockchain
              puts 'minting error' + e.inspect
            end  
          end
        end
      end
    end
  end


  
  
end
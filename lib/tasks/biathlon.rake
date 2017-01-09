def get_feed(url = '')
  response = HTTParty.get(Figaro.env.dapp_address + url)
  return response.parsed_response
  
end

def account_balance(url = '/account_balance', account)
  response = HTTParty.post(Figaro.env.dapp_address + url, {account: account})
  return response.parsed_response
end

namespace :bidapp do
  
  desc 'Confirm all unconfirmed Ethereum transactions'
  task confirm_all: :environment do
    api = BidappApi.new
    transactions = Ethtransaction.unconfirmed.order(id: :asc)
    transactions.each do |tx|
      # p 'checking ' + tx.txaddress  
      check = api.confirm(tx.txaddress)
      tx.checked_confirmation_at = Time.now
      if check['success']
        tx.confirmed = true
        # p 'confirmed on blockchain ' + tx.txaddress
      elsif check['error']
        # p 'No confirmation for ' + tx.txaddress
      end
      tx.save(validate: false)
    end
  end
  
  
  desc 'Check all accounts under coinbase and synchronise with postgres'
  task sync_accounts: :environment do
    mainfeed = get_feed
    mainfeed['data']['accounts'].each do |acc|
      a = Account.where("external is not true").find_or_create_by(address: acc.first)
      a.balance = acc.last['biathlon'].to_i rescue 0

      if a.changed?
        a.save
        next if a.user.nil?
        a.user.latest_balance = a.balance
        a.user.save!
      end
    end
    
    # check external accounts
    api = BidappApi.new
    externals = Account.external.each do |acc|
      api_data = api.api_post('/account_balance', {account: acc.address})
      acc.balance = api_data.to_i rescue 0
      if acc.changed?
        acc.save
        next if acc.user.nil?
        acc.user.latest_balance = acc.balance
        acc.user.save!
      end      
    end
  end
  

  desc 'audit user accounts on blockchain'
  task audit_users: :environment  do
    api = BidappApi.new
    User.all.order(:id).each do |user|
      unless user.all_activities.empty?
        total = 0
        plus = user.all_activities.select{|x| x.addition == 1}.sum{|x| x.value.to_i} 
        minus =  user.all_activities.select{|x| x.addition == -1}.sum{|x| x.value.to_i}
        plus2 = user.all_activities.select{|x| x.description =~ /received/ && x.user == user }.sum{|x| x.value.to_i}
        minus2 = user.all_activities.select{|x| x.description =~ /received/ && x.item == user }.sum{|x| x.value.to_i}
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
              transaction = api.spend(user.accounts.primary.first.address, user.latest_balance - total)
              if transaction['data']
                et = nil
                sleep 2
                while et.nil? do
                  et = Ethtransaction.find_by(txaddress: transaction['data'])
                end
                a = Activity.create(user: user, item_type: 'Post', item_id: 8, ethtransaction_id: et.id, 
                description: "had their blockchain balance adjusted by -#{user.latest_balance - total}#{ENV['currency_symbol']}", 
                addition: 0, txaddress: transaction['data'])
              elsif transaction['error']
                return transaction['error']
              end
            rescue Exception => e
              # don't write anything unless it goes to blockchain
              logger.warn('spending error' + e.inspect)  
              return transaction
            end  
          elsif user.latest_balance < total
            p '  -- will add ' + (total - user.latest_balance).to_s + ' from blockchain balance'
            begin
              transaction = api.mint(user.accounts.first.address, total - user.latest_balance)
              if transaction['data']
                et = nil
                sleep 2
                while et.nil? do
                  et = Ethtransaction.find_by(txaddress: transaction['data'])
                end
                a = Activity.create(user: user, item_type: 'Post', item_id: 8, ethtransaction_id: et.id, 
                description: "had their blockchain balance adjusted by +#{total - user.latest_balance}#{ENV['currency_symbol']}", 
                addition: 0, txaddress: transaction['data'])
              elsif transaction['error']
                return transaction['error']
              end
            rescue Exception => e
              # don't write anything unless it goes to blockchain
              logger.warn('spending error' + e.inspect)  
              return transaction
            end  
          end
        end
      end
    end
  end


  
  
end
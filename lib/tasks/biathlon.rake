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
    
    # # check external accounts
    # api = BidappApi.new
    # externals = Account.external.each do |acc|
    #   api_data = api.api_post('/account_balance', {account: acc.address})
    #   acc.balance = api_data.to_i rescue 0
    #   if a.changed?
    #     a.save
    #     next if a.user.nil?
    #     a.user.latest_balance = a.balance
    #     a.user.save!
    #   end
    # end
  end
  
end
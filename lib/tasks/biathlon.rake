def get_feed(url = '')
  response = HTTParty.get(Figaro.env.dapp_address + url)
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
      a = Account.find_or_create_by(address: acc.first)
      a.balance = acc.last['biathlon'].to_i rescue 0

      if a.changed?
        a.save
        next if a.user.nil?
        a.user.latest_balance = a.balance
        a.user.save!
      end
    end
  end
  
end
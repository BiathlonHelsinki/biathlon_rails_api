def get_feed(url = '')
  response = HTTParty.get(Figaro.env.dapp_address + url)
  return response.parsed_response
  
end

namespace :bidapp do
  desc 'Check all accounts under coinbase and synchronise with postgres'
  task sync_accounts: :environment do
    mainfeed = get_feed
    mainfeed['data']['accounts'].each do |acc|
      a = Account.find_or_create_by(address: acc.first)
      a.balance = acc.last['biathlon'].to_i rescue 0
      a.save if a.changed?
    end
  end
  
end
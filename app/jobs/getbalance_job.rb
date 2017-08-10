class GetbalanceJob < ApplicationJob
  queue_as :default

  def perform(user)
    api = BidappApi.new
    oldbalance = user.latest_balance
    begin
      api_data = api.api_post('/account_balance', {account: user.accounts.primary.first})
      user.latest_balance = api_data.to_i
    rescue
      
    end
    
  end
  
end
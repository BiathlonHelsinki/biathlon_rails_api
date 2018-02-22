class GetbalanceJob < ApplicationJob
  queue_as :default

  def perform(user)
    api = BidappApi.new
    oldbalance = user.latest_balance
    begin
      api_data = api.get_balance(user.get_eth_address)
      user.latest_balance = api_data['success'].to_i
    rescue
      
    end
    
  end
  
end
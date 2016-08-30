class TransfersController < ApplicationController
  
  
  before_action :authenticate_user!
  
  def send_biathlon
    recipient = User.friendly.find(params[:user_id])
    sender = current_user
    # check if recipient has ethereum account yet
    if recipient.accounts.empty?
      create_call = HTTParty.post(Figaro.env.dapp_address + '/create_account',
                                   body: {password: recipient.geth_pwd})
      unless JSON.parse(create_call.body)['data'].blank?
        recipient.accounts << Account.create(address: JSON.parse(create_call.body)['data'])
      end
    end
    
    # account is created in theory, so now let's do the transaction
    api = BidappApi.new
    begin
      transaction = api.transfer(sender.accounts.first.address, recipient.accounts.first.address, params[:points], sender.geth_pwd)
      logger.warn('transaction is ' + transaction)
      

      Activity.create(user: current_user, item: recipient,
        ethtransaction: Ethtransaction.find_by(txaddress: transaction),
        description: "transfered #{params[:points]}#{ENV['currency_symbol']} to ", extra_info: params[:reason].blank? ? nil : " (reason: #{params[:reason]})" 
        )
      sender.update_balance_from_blockchain
      recipient.update_balance_from_blockchain
      render json: {data: Ethtransaction.find_by(txaddress: transaction)}, status: 200
    rescue => e
      render json: {error: e.inspect }, status: :unprocessable_entity
    end
    # fix this
    # accounts.first.balance = accounts.first.balance.to_i + points
    # save(validate: false)
    
  end
  
end
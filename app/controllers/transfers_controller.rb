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
    # api = BidappApi.new
    begin
      # if sender.accounts.primary.first.external == true

       b = BlockchainTransaction.new(value: params[:points], account: sender.accounts.first, recipient: recipient.accounts.first,  transaction_type: TransactionType.find_by(name: 'Transfer'))
        # transaction = api.transfer(sender.accounts.first.address, recipient.accounts.first.address, params[:points])
      # else
        # transaction = api.transfer(sender.accounts.first.address, recipient.accounts.first.address, params[:points])
         #, sender.geth_pwd)
      # end
      # if JSON.parse(transaction)['error']
 #        render json: {error: JSON.parse(transaction)['error']}, status: 400
 #      else
 #        sleep 2
        # et = nil
        # loop do
          # et = Ethtransaction.find_by(txaddress: JSON.parse(transaction)['data'])
        #   sleep 1
        #   break if !et.nil?
        # end

        a = Activity.create(user: recipient, item: current_user,
          ethtransaction: nil, addition: 0, txaddress: nil,
          description: "received_from", extra_info: params[:reason].blank? ? nil : " (reason: #{params[:reason]})", blockchain_transaction: b
          )
        if b.save
          BlockchainHandlerJob.perform_later b
        end  
        sender.latest_balance = sender.latest_balance - params[:points].to_i
        recipient.latest_balance = recipient.latest_balance + params[:points].to_i
        sender.save
        recipient.save
        render json: {data: current_user}, status: 200
    rescue => e
      logger.warn('errs are ' + e.inspect)
      render json: {error: e.inspect }, status: :unprocessable_entity
    end
    # fix this
    # accounts.first.balance = accounts.first.balance.to_i + points
    # save(validate: false)
    
  end
  
end
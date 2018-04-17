class UserphotoslotsController < ApplicationController
  
  
  before_action :authenticate_user!
  
  def buy_slot
    user = User.friendly.find(params[:user_id])
    if current_user == user
      if user.accounts.empty?
        render json: {error: 'User does not have an Ethereum account' }, status: :unprocessable_entity
      else
      
        begin
          @userphotoslot = Userphotoslot.create(user: user )
        
          b = BlockchainTransaction.new(value: 1, account: user.accounts.first, transaction_type: TransactionType.find_by(name: 'Spend'))
          a = Activity.create(user: user, contributor: user, item: @userphotoslot, ethtransaction: nil, addition: -1, txaddress: nil, description: "bought_a_photo_upload_slot", blockchain_transaction: b)

          if b.save
            BlockchainHandlerJob.perform_later b
          else
            die
            render json: {error: e.inspect }, status: :unprocessable_entity
          end
          @userphotoslot.activity = a
          user.update_attribute(:latest_balance, user.latest_balance - 1)
          @userphotoslot.save
          render json: {data: current_user}, status: 200
        rescue => e
          logger.warn('errs are ' + e.inspect)
          render json: {error: e.inspect }, status: :unprocessable_entity
        end
      end
    end
  end
  
  
end
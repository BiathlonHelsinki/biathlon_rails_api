class StakesController < ApplicationController

  before_action :authenticate_user!

  def award_stake_points
    @stake = Stake.find(params[:id])
    if @stake.blockchain_transaction.nil? && @stake.paid == true
      b = BlockchainTransaction.new(value: @stake.amount * 500, 
        account: Account.find_by(address: @stake.owner.get_eth_address),
        transaction_type: TransactionType.find_by(name: 'Create'))
      a = Activity.create(contributor: @stake.owner, user: current_user,
                          item: @stake, addition: 1, ethtransaction: nil, 
                          description: 'received_stake_points', 
                          blockchain_transaction: b)
      if b.save
       BlockchainHandlerJob.perform_later b
        render json: {"status" => "success"}.to_json
      else
        render json: {"status" => "error", "message" => b.errors.inspect}.to_json
      end
    end          
  end

end
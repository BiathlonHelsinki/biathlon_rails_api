class BlockchainHandlerJob < ApplicationJob
  queue_as :default

  def perform(blockchaintransaction)
    if !blockchaintransaction.confirmed_at.nil?
      return true
    elsif blockchaintransaction.submitted_at.nil?
      api = BidappApi.new
      if blockchaintransaction.transaction_type_id == 1
        transaction = api.mint(blockchaintransaction.account.address, blockchaintransaction.value)
      elsif blockchaintransaction.transaction_type_id == 2
        transaction = api.spend(blockchaintransaction.account.address, blockchaintransaction.value)
      elsif blockchaintransaction.transaction_type_id == 3
        transaction = api.transfer(blockchaintransaction.account.address, blockchaintransaction.recipient.address, blockchaintransaction.value)
      end
      sleep 4
      if transaction['data']
        et = Ethtransaction.find_by(txaddress: transaction['data'])
        blockchaintransaction.ethtransaction = et
        blockchaintransaction.activity.ethtransaction = et
        blockchaintransaction.submitted_at = Time.current
        blockchaintransaction.save
        blockchaintransaction.activity.save
      else
        logger.warn('errors: ' + transaction.inspect)
      end
      
    end
  end
end

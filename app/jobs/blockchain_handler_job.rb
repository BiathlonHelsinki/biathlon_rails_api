class BlockchainHandlerJob < ApplicationJob
  queue_as :default
  
  include ActiveJob::Retry.new(strategy: :constant,
                               limit: 5,
                               delay: 5.minutes)


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
      sleep 3
      if transaction
        if transaction['status'] != 'error'
          logger.warn(transaction.inspect)
          et = Ethtransaction.find_by(txaddress: transaction['success'])
          blockchaintransaction.ethtransaction = et
          blockchaintransaction.activity.ethtransaction = et
          blockchaintransaction.submitted_at = Time.current
          blockchaintransaction.save
          blockchaintransaction.activity.save
          if blockchaintransaction.activity.item_type == 'Stake'
            if blockchaintransaction.activity.item.ethtransaction.nil?
              blockchaintransaction.activity.item.ethtransaction = et
              blockchaintransaction.activity.item.save
            end
          end
        else
          raise "DappException"
        end
      end
    end
  end
end

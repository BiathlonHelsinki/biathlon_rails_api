class BlockchainHandlerJob < ApplicationJob
  queue_as :default
  
  # include ActiveJob::Retry.new(strategy: :constant,
  #                              limit: 5,
  #                              delay: 5.minutes)


  def perform(blockchaintransaction)
    if !blockchaintransaction.confirmed_at.nil?
      return true
    elsif blockchaintransaction.submitted_at.nil?
      api = BidappApi.new
      blockchaintransaction.update_column(:submitted_at, Time.current)
      if blockchaintransaction.transaction_type_id == 1
        transaction = api.mint(blockchaintransaction.account.address, blockchaintransaction.value, blockchaintransaction.id)
      elsif blockchaintransaction.transaction_type_id == 2
        transaction = api.spend(blockchaintransaction.account.address, blockchaintransaction.value, blockchaintransaction.id)
      elsif blockchaintransaction.transaction_type_id == 3
        transaction = api.transfer(blockchaintransaction.account.address, blockchaintransaction.recipient.address, blockchaintransaction.value, blockchaintransaction.id)
      end
      sleep 3
      if transaction
        if transaction['status'] != 'error'
          blockchaintransaction.update_column(:submitted_at, Time.current)
          # logger.error(transaction.inspect)
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
          logger.error('error on Dapp' + transaction.inspec)
          blockchaintransaction.update_column(:submitted_at, Time.current)
          raise "DappException"
        end
      end
    end
  end
end

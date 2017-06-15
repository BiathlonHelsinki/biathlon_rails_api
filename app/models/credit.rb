class Credit < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  belongs_to :awarder, class_name: 'User'
  belongs_to :ethtransaction
  belongs_to :rate
  mount_uploader :attachment, AttachmentUploader
  has_many :activities, as: :item,  dependent: :destroy
  before_save :update_attachment_metadata

  validates_numericality_of :value, :greater_than_or_equal_to => 0
  validates_presence_of :user_id, :awarder_id, :description, :value, :rate_id
  after_create :award_points
  before_destroy :remove_points
  
  def remove_points
    # api = BidappApi.new
 #    transaction = api.spend(user.accounts.primary.first.address, value)
    b = BlockchainTransaction.new(value: value, account: user.accounts.primary.first, transaction_type: TransactionType.find_by(name: 'Spend'))
    user.accounts.primary.first.balance = user.accounts.primary.first.balance.to_i - value
    user.save(validate: false)
    # et = Ethtransaction.find_by(txaddress: transaction)
    # die if et.nil?
    # 
    activities <<  Activity.create(user: user, item: self, ethtransaction_id: nil, description: 'was de-credited for', addition: -1, blockchain_transaction: b)
    if b.save
      BlockchainHandlerJob.perform_later b
    end
    
  end
  
  def award_points
    # check if user has ethereum account yet
    if user.accounts.empty?
      create_call = HTTParty.post(Figaro.env.dapp_address + '/create_account', body: {password: user.geth_pwd})
      unless JSON.parse(create_call.body)['data'].blank?
        user.accounts << Account.create(address: JSON.parse(create_call.body)['data'], primary_account: true)
        user.save
      end
    end
    
    b = BlockchainTransaction.new(value: value, account: user.accounts.primary.first, transaction_type: TransactionType.find_by(name: 'Create'))
    a = Activity.new(user: user, item: self, description: 'was credited for', addition: 1, blockchain_transaction: b)
    if b.save
      a.save
      BlockchainHandlerJob.perform_later b
      return true
    else
      self.errors.add(:base, 'Could not queue transaction for blockchain')
    end
    # NEW - queue this
    # account is created in theory, so now let's do the transaction
    # api = BidappApi.new
    #     transaction = api.mint(user.accounts.primary.first.address, value)
    #     user.accounts.primary.first.balance = user.accounts.primary.first.balance.to_i + value
    #     user.latest_balance = user.accounts.primary.first.balance
    #     if user.save(validate: false)
    #       logger.warn('saved updated balance of ' + user.accounts.primary.first.balance.to_s)
    #     else
    #       logger.warn('error because of ' + user.errors.inspect)
    #     end
    #     # get transaction hash and add to activity feed. TODO: move to concern!!
    #     sleep 2
    #     et = Ethtransaction.find_by(txaddress: transaction['data'])
    #     self.ethtransaction = et

  end
  
  private
  
  def update_attachment_metadata
     if attachment.present? && attachment_changed?
       if attachment.file.exists?
         self.attachment_content_type = attachment.file.content_type
         self.attachment_size = attachment.file.size
       end
     end
   end
   
end

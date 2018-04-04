class User < ActiveRecord::Base
  rolify
  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/
  
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable,
          :omniauthable #, :confirmable
  has_many :accounts, as: :holder
  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications, :reject_if => proc { |attr| attr['username'].blank? }
  acts_as_token_authenticatable
  # validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update
  extend FriendlyId
  friendly_id :username , :use => [ :slugged, :finders, :history]
  has_many :activities
  has_many :own_activities, as: :contributor, class_name: 'Activity'
  has_many :onetimers
  has_many :nfcs
  has_many :stakes, dependent: :destroy, as: :owner
  # has_and_belongs_to_many :events
  # has_many :activities, as: :item
  has_many :instances_users
  has_many :ideas, as: :proposer
  has_many :instances, through: :instances_users
  scope :untagged, -> () { includes(:nfcs).where( nfcs: {user_id: nil}) }
  mount_uploader :avatar, ImageUploader
  before_save :update_avatar_attributes
  # validates_presence_of :geth_pwd
  has_and_belongs_to_many :events  
  has_many :members, dependent: :destroy
  has_many :groups, through: :members, source: :source, source_type: 'Group'

  def charge_vat?
    false
  end

  def has_pin
    !pin.blank? 
  end

  def eth_address
    if accounts.empty?   
      # TODO -- create a new account here and return the eth address
    else
      accounts.first.address
    end
  end

  def events_attended
    instances.size
  end
  
  def last_attended
    instances.order(:created_at).last
  end
  
  def last_attended_at
    if instances_users.empty?
      nil
    else
      instances_users.where(user: self, instance: instances.order(:created_at).last).first.visit_date
    end
  end

  def get_eth_address
    if accounts.empty?
      @dapp_status = Net::Ping::TCP.new(ENV['dapp_server'],  ENV['dapp_port'], 1).ping?
      if !@dapp_status
        return {"status" => "error", "message" => 'The Biathlon Dapp is not running!'}
      else
        begin
          create_call = HTTParty.post(Figaro.env.dapp_address + '/create_account', body: {password: self.geth_pwd})
          if JSON.parse(create_call.body)['success'].blank?
            logger.warn('error is ' + JSON.parse(create_call.body)['error'].inspect)
            exit
          else
            accounts << Account.create(address: JSON.parse(create_call.body)['success'])
          end
        rescue Exception => e
          return {"status" => "error", "message" => e.inspect }
        end
      end
    end
    return accounts.first.address
  end
  
  def copy_password
    geth_pwd = SecureRandom.hex(13)
  end
  
  # has_many :activities, as: :item
  
  def email_required?
    false
  end
  
  def all_activities
    [activities, Activity.where(item: self)].flatten.compact.uniq    
  end
  
  def self_activities_kp
    [activities.kuusi_palaa, Activity.kuusi_palaa.where(item: self)].flatten.compact.uniq    
  end


  def available_balance
    latest_balance - pending_pledges.sum(&:pledge)      
  end
  
  def update_balance_from_blockchain
    api = BidappApi.new
    accounts.each do |account|
      begin
        api_data = api.api_post('/account_balance', {account: account.address})
        account.balance = api_data.to_i
        account.save
      rescue
        next
      end
    end
    self.latest_balance = accounts.sum(&:balance)
    self.latest_balance_checked_at = Time.now
    save(validate: false)
  end
  
  def should_generate_new_friendly_id?
     username_changed?
   end
   
  def award_points(instance, points = 10, visit_date = Time.now.to_date)
    # check user hasn't already attended, locally
    if instances.include?(instance)
      if instance.allow_multiple_entry == true
        if !instances_users.where(instance: instance, visit_date: visit_date).empty?
          
          errors.add(:base, :already_attended, message: 'You have already attended this event on ' + visit_date.to_s)
          return false
        end
      else
        errors.add(:base, :already_attended, message: 'You have already attended this event')
        return false
      end
    end


      # if errors.nil?
        # account is created in theory, so now let's do the transaction
        # no longer logging blockchain on the fly, but queing to process later
        # api = BidappApi.new

        address = self.get_eth_address
        logger.warn "got here, address should be " + address
        begin
          # 1. make activity first with blank transaction
          b = BlockchainTransaction.new( value: points, account: Account.find_by(address: address), transaction_type: TransactionType.find_by(name: 'Create'))
          a = Activity.create(user: self, contributor: self, item: instance, addition: 1, ethtransaction: nil, description: 'attended', blockchain_transaction: b)
          
          # 2. make instance_user
          instances_users << InstancesUser.new(instance: instance, visit_date: visit_date, activity: a)
          
          # 3. submit transaction, get hash

          # 3 NEW: submit to blockchain queue
         
          if b.save
             BlockchainHandlerJob.perform_later b
            return {"status" => "success"}
          else
            return {"error" => "error", "message" => b.errors.inspect}
          end
          # transaction = api.mint(self.accounts.first.address, points)
          #
          # if transaction['data']
          #   logger.warn('address is ' + transaction['data'])
          #   accounts.first.balance = accounts.first.balance.to_i + points
          #   sleep 1
          #   e = Ethtransaction.find_by(txaddress: transaction['data'])
          #
          #   # 4. add hash to activity
          #   a.ethtransaction = e
          #   a.txaddress = transaction['data']
          #   if a.save
          #     save
          #     return transaction
          #   else
          #     # logger.warn('errors are ' + a.errors.inspect)
          #     return false
          #   end
          #   # logger.warn('hmmmm ..... ' + transaction)
          # elsif transaction['error']
          #
          #   logger.warn('message is ' + transaction[:message].to_s)
          #   return transaction
          # elsif transaction['status'] == 'error'
          #   logger.warn('third error:' + transaction.inspect)
          #   return transaction
          #
          # else
          #   logger.warn('none of the above: ' + transaction.inspect)
          # end
      #
      #   rescue Net::ReadTimeout
      #     return {error: {message: 'There was a problem communicating with the Ethereum blockchain. Your check-in has been logged and will be resubmitted later. Enjoy the experiment!'}}
      #   rescue Exception => e
      #     # don't write anything unless it goes to blockchain
      #     logger.warn('minting error: ' + e.inspect)
      #     return transaction
      #   end
      # else
      #   logger.warn('wtf')
      #
      #   self.errors.add(:base, error.inspect)
      #   return false
      # else 
      #   logger.warn errors.inspect
      #   return errors
      # end

    end
  end
  
   def is_stakeholder?
    !stakes.paid.empty? || !groups.map(&:stakes).flatten.delete_if{|x| x.paid != true}.empty?
  end

  def is_member?
    !stakes.where(includes_share: true).empty? && accepted_agreement == true
  end

  def self.find_for_oauth(auth, signed_in_resource = nil)

     # Get the identity and user if they exist
     identity = Authentication.find_for_oauth(auth)

     # If a signed_in_resource is provided it always overrides the existing user
     # to prevent the identity being locked with accidentally created accounts.
     # Note that this may leave zombie accounts (with no associated identity) which
     # can be cleaned up at a later date.
     user = signed_in_resource ? signed_in_resource : identity.user

     # Create the user if needed
     if user.nil?

       # Get the existing user by email if the provider gives us a verified email.
       # If no verified email was provided we assign a temporary email and ask the
       # user to verify it on the next step via UsersController.finish_signup
       email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
       email = auth.info.email if email_is_verified
       user = User.where(:email => email).first if email

       # Create the user if it's a new registration
       if user.nil?
         user = User.new(
           name: auth.extra.raw_info.name,
           #username: auth.info.nickname || auth.uid,
           email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
           password: Devise.friendly_token[0,20]
         )
         user.skip_confirmation!
         user.save!
       end
     end

     # Associate the identity with the user if needed
     if identity.user != user
       identity.user = user
       identity.save!
     end
     user
   end

   def email_verified?
     self.email && self.email !~ TEMP_EMAIL_REGEX
   end
   
   def has_pledged?(proposal)
     pledges.where(item: proposal).any?
   end
     
   def pending_pledges
     pledges.to_a.delete_if{|x| x.converted == 1}
   end
   
  
   def display_name
     if show_name == true
       "#{name} (#{username})"
     else
       username
     end
   end
  
  
  def apply_omniauth(omniauth)
    if omniauth['provider'] == 'twitter'
      logger.warn(omniauth.inspect)
      self.username = omniauth['info']['nickname']
      self.name = omniauth['info']['name']
      self.name.strip!
      identifier = self.username

    elsif omniauth['provider'] == 'facebook'
      self.email = omniauth['info']['email'] if email.blank? || email =~ /change@me/
      self.username = omniauth['info']['name']
      self.name = omniauth['info']['name'] 
      self.name.strip!
      identifier = self.username
      # self.location = omniauth['extra']['user_hash']['location']['name'] if location.blank?
    elsif omniauth['provider'] == 'google_oauth2'
      self.email = omniauth['info']['email'] 
      self.name = omniauth['info']['name']
      self.username = omniauth['info']['email']
      identifier = self.username
    end
    if email.blank?
      if omniauth['info']['email'].blank?
        self.email = "#{TEMP_EMAIL_PREFIX}-#{omniauth['uid']}-#{omniauth['provider']}.com"
      else
        self.email = omniauth['info']['email']
      end
    end
    
    self.password = SecureRandom.hex(32) if password.blank?  # generate random password to satisfy validations
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :username => identifier)
  end
  
  def update_avatar_attributes
    if avatar.present? && avatar_changed?
      if avatar.file.exists?
        self.avatar = avatar.file.content_type
        self.avatar_size = avatar.file.size
        self.avatar_width, self.avatar_height = `identify -format "%wx%h" #{avatar.file.path}`.split(/x/)
      end
    end
  end
  
end

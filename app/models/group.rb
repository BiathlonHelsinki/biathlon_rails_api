class Group < ApplicationRecord
  has_many :members, dependent: :destroy, as: :source
  has_many :users, through: :members
  has_many :stakes, dependent: :destroy, as: :owner
  has_many :owners,
   -> { where(members: { access_level: KuusiPalaa::Access::OWNER }) },
   through: :members,
   source: :user
  extend FriendlyId
  has_many :accounts, as: :holder
  has_many :pledges, as: :pledger
  friendly_id :name , :use => [ :slugged, :finders, :history]
  mount_uploader :avatar, ImageUploader
  before_save :update_avatar_attributes
  # process_in_background :avatar
  validates_presence_of :name
  validate :uniqueness_of_a_name
  before_create :at_least_one_member
  after_create :add_to_activity_feed
  after_update :edit_to_activity_feed
  before_save :validate_vat
  has_many :activities, as: :contributor
  has_many :own_activities, as: :contributor, class_name: 'Activity'
  rolify

  def all_activities
    [activities, Activity.where(item: self)].flatten.compact.uniq    
  end
  
  def self_activities_kp
    [activities.kuusi_palaa, Activity.kuusi_palaa.where(item: self)].flatten.compact.uniq    
  end

  
  def validate_vat
    unless taxid.blank?
      unless country == 'FI' || country.blank?
        self.valid_vat_number = Valvat.new(taxid).valid?
      else
        self.valid_vat_number = false
      end
    else
      self.valid_vat_number = false
    end
  end

  def at_least_one_member

  end

  def stake_price
    if is_member && !taxid.blank?
      return 75
    else
      if taxid.blank?
        return 50
      else
        return 100
      end
    end
  end

  def is_stakeholder?
    if is_member && !taxid.blank?
      return !stakes.paid.empty?
    else
      if taxid.blank?
        return !stakes.paid.empty?
      else
        return false
      end
    end
  end
  
  def copy_password
    geth_pwd = SecureRandom.hex(13)
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
            return {"status" => "error", "message" => e.inspect }
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

  def charge_vat?
    if is_member
      return false
    else  #could be unregistered
      if !taxid.blank?
        if country == 'FI'
          return true
        else
          if valid_vat_number == true
            return false
          else
            return true
          end
        end
      else
        return false
      end
    end
  end

  def display_name
    if long_name.blank?
      name
    else
      long_name
    end
  end

  def uniqueness_of_a_name
    self.errors.add(:name, 'is already taken') if User.where("lower(username) = ?", self.name.downcase).exists?
    if new_record?
      self.errors.add(:name, 'is already taken') if Group.where(["lower(name) = ? ", self.name.downcase]).exists?
    else
      self.errors.add(:name, 'is already taken') if Group.where("lower(name) = ? and id <> ?", self.name.downcase, self.id).exists?
    end
  end

  def edit_to_activity_feed
    Activity.create(user: self.members.first.user, item: self, description: "edited_the_group",  addition: 0)
  end

  def add_to_activity_feed
    Activity.create(user: self.members.first.user, item: self, description: "created_the_group",  addition: 0)
  end

  def update_avatar_attributes
    if avatar.present? && avatar_changed?
      if avatar.file.exists?
        self.avatar_content_type = avatar.file.content_type
        self.avatar_size = avatar.file.size rescue 0
        self.avatar_width, self.avatar_height = `identify -format "%wx%h" #{avatar.file.path}`.split(/x/) rescue nil
      end
    end
  end

end

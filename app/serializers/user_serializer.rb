class UserSerializer 
  include FastJsonapi::ObjectSerializer
  has_many :accounts
  
  attributes :slug, :id, :email, :name, :username, :has_pin, :created_at, :updated_at,
   :latest_balance, :events_attended, :last_attended, :last_attended_at, :avatar, :eth_address
  


end

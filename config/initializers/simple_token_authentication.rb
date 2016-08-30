SimpleTokenAuthentication.configure do |config|
  config.identifiers = { user: :email, hardware: :mac_address }
end

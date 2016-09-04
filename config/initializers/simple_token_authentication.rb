SimpleTokenAuthentication.configure do |config|
  config.identifiers = { user: :email, hardware: :name }
end

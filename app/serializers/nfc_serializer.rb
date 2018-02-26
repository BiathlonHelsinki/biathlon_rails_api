class NfcSerializer 
  include FastJsonapi::ObjectSerializer
  attributes :id,  :tag_address, :security_code, :holder_name

  
end

CarrierWave.configure do |config|  
    config.storage = :aws
    config.aws_credentials = {
      :access_key_id      => ENV['amazon_access_key'],
      :secret_access_key  => ENV['amazon_secret'], 
      region: 'eu-central-1'
    }
    config.aws_acl    = :public_read

    config.aws_bucket  = "biathlon-#{Rails.env.to_s}"


  # config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end

# CarrierWave::Backgrounder.configure do |c|
#   c.backend :delayed_job, queue: :carrierwave
#   # c.backend :active_job, queue: :carrierwave
#   # c.backend :resque, queue: :carrierwave
#   # c.backend :sidekiq, queue: :carrierwave
#   # c.backend :girl_friday, queue: :carrierwave
#   # c.backend :sucker_punch, queue: :carrierwave
#   # c.backend :qu, queue: :carrierwave
#   # c.backend :qc
# end

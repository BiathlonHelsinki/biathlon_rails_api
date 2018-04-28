CarrierWave.configure do |config|  
    config.storage = :aws
    config.ignore_integrity_errors = false
    config.ignore_processing_errors = false
    config.ignore_download_errors = false
    config.aws_credentials = {
      :access_key_id      => ENV.fetch('amazon_access_key'),
      :secret_access_key  => ENV.fetch('amazon_secret'),
      region: 'eu-central-1'
    }
    config.asset_host = "https://biathlon-#{Rails.env}.s3.eu-central-1.amazonaws.com"
    config.aws_acl    = 'public-read'

    config.aws_bucket  = "biathlon-#{Rails.env}"

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

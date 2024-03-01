CarrierWave.configure do |config|
  if Rails.env.production? || Rails.env.staging?
    config.fog_directory = ENV.fetch("aws_directory")
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV.fetch("aws_access_key_id"),
      aws_secret_access_key: ENV.fetch("aws_secret_access_key"),
      region: ENV.fetch("aws_region")
    }
  end
end

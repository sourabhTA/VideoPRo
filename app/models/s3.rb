class S3
  def self.config
    {
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      region: region,
      bucket_name: bucket_name
    }
  end

  def self.access_key_id
    ENV.fetch("aws_access_key_id")
  end

  def self.secret_access_key
    ENV.fetch("aws_secret_access_key")
  end

  def self.region
    ENV.fetch("aws_region")
  end

  def self.bucket_name
    ENV.fetch("aws_directory")
  end
end

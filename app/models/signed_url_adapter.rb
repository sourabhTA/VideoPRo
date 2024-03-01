require "aws-sdk-s3"

class SignedUrlAdapter
  attr_reader :archive_id, :download_name

  def initialize(archive_id:, download_name:)
    @archive_id = archive_id
    @download_name = download_name
  end

  def valid?
    download_name.present? && archive_id.present?
  end

  def signed_url
    return nil unless valid?
    options = {
      response_content_disposition: "attachment; filename=\"#{download_name}.mp4\"",
      expires_in: 90
    }

    obj = bucket.object(file_path)
    obj.exists? ? obj.presigned_url(:get, options) : nil
  end

  private

  def file_path
    Pathname.new(OpenTokClient.api_key).join(archive_id).join("archive.mp4").to_s
  end

  def bucket
    @bucket ||= begin
      s3_config = S3.config

      Aws.config.update({
        region: s3_config[:region],
        credentials: Aws::Credentials.new(s3_config[:access_key_id], s3_config[:secret_access_key])
      })
      Aws::S3::Resource.new.bucket(s3_config[:bucket_name])
    end
  end
end

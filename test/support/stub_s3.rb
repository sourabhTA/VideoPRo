require "aws-sdk-s3"

module StubS3
  def stub_open_tok
    OpenTokClient.stub(:api_key, "/ot_api_key") do
      OpenTokClient.stub(:generate_token, "token") do
        yield if block_given?
      end
    end
  end

  def stub_s3
    s3 = {
      access_key_id: "aid",
      secret_access_key: "secret",
      region: "us-west-2",
      bucket_name: "example.com"
    }

    resource = MiniTest::Mock.new
    def resource.bucket(options)
      Bucket.new
    end

    S3.stub(:config, s3) do
      Aws::S3::Resource.stub(:new, resource) do
        yield if block_given?
      end
    end
  end

  class Bucket
    attr_accessor :path

    def exists?
      true
    end

    def presigned_url(method, options)
      path
    end

    def object(path)
      Bucket.new.tap do |b|
        b.path = path
      end
    end
  end
end

class OpenTokClient
  class DevClient
    def generate_token(session_id, params)
      SecureRandom.uuid
    end

    def create_session(options)
      self
    end

    def session_id
      SecureRandom.uuid
    end
  end

  def self.api_key
    ENV.fetch("opentok_api_key")
  end

  def self.api_secret
    ENV.fetch("opentok_api_secret")
  end

  def self.generate_token(session_id, params = nil)
    new.client.generate_token(session_id, params)
  end

  def self.create_session(options)
    new.client.create_session(options)
  end

  def client
    @client ||= if Rails.env.production? || Rails.env.staging? || (Rails.env.development? && ENV["opentok_api_key"].present?)
      OpenTok::OpenTok.new(
        self.class.api_key,
        self.class.api_secret
      )
    else
      DevClient.new
    end
  end
end

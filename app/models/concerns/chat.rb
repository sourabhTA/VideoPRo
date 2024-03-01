# Provides a conforming interface for "chat" like models
# These method ensure you implement all method of the interface
module Chat
  def minutes_available?
    raise "##{__method__} must be defined"
  end

  def early_link?
    raise "##{__method__} must be defined"
  end

  def expired_link?
    raise "##{__method__} must be defined"
  end

  def payments_made?
    raise "##{__method__} must be defined"
  end

  def pro_name
    raise "##{__method__} must be defined"
  end

  def client_name
    raise "##{__method__} must be defined"
  end

  def end_call(seconds, end_time, connection_id)
    raise "##{__method__} must be defined"
  end

  def chat_time
    raise "##{__method__} must be defined"
  end

  def charged_amount
  end

  def review_for_id
  end
end

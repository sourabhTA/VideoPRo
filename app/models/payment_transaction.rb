class PaymentTransaction < ApplicationRecord
  belongs_to :booking

  def VCAP_share
    amount && customer_amount ? amount - customer_amount : 0
  end

  def total_captured
    net_amount && stripe_fee ? net_amount + stripe_fee : 0
  end
end

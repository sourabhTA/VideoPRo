class StripeProcessorException < RuntimeError; end

class StripeProcessor
  attr_accessor :booking, :order, :time

  def initialize(booking, time)
    @booking = booking
    @time = time
  end

  def process
    if booking.is_booking_fake
      fake_process!
      fake_success?
    else
      process!
      success?
    end
  end

  def fake_process!
    @transaction = PaymentTransaction.new
    @transaction.booking_id = @booking.id
    @transaction.amount = 0
    @transaction.time_used = @time
    @transaction.transaction_code = "fake_transaction_code"
    @transaction.transaction_status = "paid"
    @transaction.balance_transaction_id = "fake_balance_transaction_id"
    @transaction.net_amount = 0
    @transaction.application_fee = 0
    @transaction.stripe_fee = 0
    @transaction.customer_amount = 0
    @transaction.save
  end

  def process!
    @booking.payment_transactions.each do |pt|
      if @time > 0
        charge_time = @time.to_i > pt.call_time_booked ? pt.call_time_booked : @time
        cal_amount = ( @booking.total_donation(charge_time) * 100 ).ceil
        pt_amount = pt.amount_captured.to_i

        amount = cal_amount > pt_amount ? pt_amount : cal_amount
        tranfer_amount = (amount * ( @booking.percentage_got_by_user )).ceil

        @response = Stripe::Charge.capture(pt.charge_id, amount: amount, transfer_data: {amount: tranfer_amount})
        @time = @time.to_i - pt.call_time_booked.to_i
        Rails.logger.warn @response.inspect

        if @response.status == "succeeded"
          pt.amount = @response.amount_captured.to_f / 100
          pt.amount_refund = @response.amount_refunded.to_f / 100
          pt.customer_amount = @response.transfer_data.amount.to_f / 100

          pt.time_used = charge_time
          pt.transaction_code = @response.id
          pt.transaction_status = "paid"
          pt.balance_transaction_id = @response.balance_transaction
          @balance_transaction = Stripe::BalanceTransaction.retrieve(pt.balance_transaction_id)

          Rails.logger.warn @balance_transaction.inspect

          pt.net_amount = @balance_transaction.net.to_f / 100
          pt.application_fee = @balance_transaction.fee.to_f / 100
          pt.stripe_fee = @balance_transaction.fee.to_f / 100
          pt.save
        end
        begin
          if cal_amount > pt_amount
            GenericMailer.send_stripe_payment_exceed(@booking, cal_amount, pt_amount).deliver_later
            Rails.logger.info "Amount to be charge : #{amount}, ------Charged amount--- #{pt_amount}--------"
            Rails.logger.info "Booking : #{@booking.inspect}, -------Payment Trans----- #{pt.inspect}-------"
          end
        rescue => e
          Rails.logger.info "Error : #{e.message}, ------- #{e.inspect}--------"
        end
      end
    end
    # @response = Stripe::Charge.create(stripe_params)
    # Rails.logger.warn @response.inspect
    # if success?
    #   @transaction = PaymentTransaction.new
    #   @transaction.booking_id = @booking.id
    #   @transaction.amount = total_donation
    #   @transaction.time_used = @time
    #   @transaction.transaction_code = @response.id
    #   @transaction.transaction_status = "paid"
    #   @transaction.balance_transaction_id = @response.balance_transaction
    #   @balance_transaction = Stripe::BalanceTransaction.retrieve(@transaction.balance_transaction_id)
    #
    #   Rails.logger.warn @balance_transaction.inspect
    #
    #   @transaction.net_amount = @balance_transaction.net.to_f / 100
    #   @transaction.application_fee = @balance_transaction.fee.to_f / 100
    #   @transaction.stripe_fee = @balance_transaction.fee.to_f / 100
    #   @transaction.customer_amount = @response.transfer_data.amount.to_f / 100
    #
    #   @transaction.save
    # end
  rescue => e
    error_message = e.message
    raise StripeProcessorException.new(error_message)
  end

  def success?
    @response.status == "succeeded"
  end

  def fake_success?
    true
  end

  private

  # def stripe_params
  #   {
  #     amount: (total_donation * 100).to_i,
  #     currency: "usd",
  #     source: @booking.stripeToken,
  #     transfer_data: {
  #       amount: ((total_donation * 100) * percentage_got_by_user).to_i,
  #       destination: @booking.user.stripe_custom_account_id
  #     }
  #   }
  # end
end

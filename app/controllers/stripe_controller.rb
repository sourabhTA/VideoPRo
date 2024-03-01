class StripeController < ApplicationController
  protect_from_forgery :except => :webhooks
  before_action :no_index

  def webhooks
    endpoint_secret = ENV.fetch("stripe_event_secret")
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      status 400
      return
    end

    Rails.logger.warn "Stripe Webhook Logs ---------------------------------------------------------------------------------------------"
    event_json = JSON.parse(request.body.read)
    Rails.logger.warn event_json.inspect
    Rails.logger.warn event_json["id"].inspect
    event = Stripe::Event.retrieve(event_json["id"])
    Rails.logger.warn "**********************************************"
    Rails.logger.warn event.type
    Rails.logger.warn "**********************************************"
    Rails.logger.warn event.inspect
    Rails.logger.warn "===================================="

    subscriber = User.find_by(stripe_customer_id: event.data.object.customer)
    raise "Subscriber not present." if subscriber.blank?

    Rails.logger.warn "**********************************************"

    if event.type == 'customer.subscription.created'
      plan  = Plan.find_by_stripe_id(event.data.object.plan.id)
      subscriber.stripe_events << subscriber.stripe_events.new(event_details: event)

      subscriber.subscribed_at = Time.at(event.data.object.start).to_datetime
      subscriber.subscription_expires_at = Time.at(event.data.object.current_period_end).to_datetime
      subscriber.seconds_left = plan.minutes_allowed * 60
      subscriber.save
      Rails.logger.info "==== Plan subscribed #{ subscriber.inspect }"
    end

    if event.type == 'customer.subscription.updated'
      plan  = Plan.find_by_stripe_id(event.data.object.plan.id)
      subscriber.stripe_events << subscriber.stripe_events.new(event_details: event)

      previous_plan = nil
      begin
        previous_plan = Plan.find_by_stripe_id(event.data.previous_attributes.plan.id)
      rescue => e
        Rails.logger.info "==== previous_plan not found  #{ event.inspect }"
      end

      unless previous_plan.nil?
        subscriber.subscribed_at = Time.at(event.data.object.start).to_datetime
        subscriber.subscription_expires_at = Time.at(event.data.object.current_period_end).to_datetime
        difference = plan.minutes_allowed - previous_plan.minutes_allowed
        subscriber.seconds_left += (difference * 60)
      else
        subscriber.seconds_left += (plan.minutes_allowed * 60)
        subscriber.subscribed_at = Time.at(event.data.object.start).to_datetime
        subscriber.subscription_expires_at = Time.at(event.data.object.current_period_end).to_datetime
      end
      subscriber.save
      Rails.logger.info "==== Plan updated #{ subscriber.inspect }"
    end

    if event.type == 'invoice.payment_succeeded'
      subscriber.stripe_events << subscriber.stripe_events.new(event_details: event)

      subscriber.stripe_payment_id = event.data.object.id
      subscriber.save
      Rails.logger.info "==== Plan Invoice success #{ subscriber.inspect }"
    end


    if event.type == 'customer.subscription.deleted'
      subscriber.stripe_events << subscriber.stripe_events.new(event_details: event)

      subscriber.subscribed_at = nil
      subscriber.subscription_expires_at = nil
      subscriber.stripe_subscription_id = nil
      subscriber.stripe_payment_id = nil
      subscriber.stripe_payment_failed_reason = nil
      subscriber.save
      Rails.logger.info "==== Plan subscription Deleted #{ subscriber.inspect }"
    end

    if event.type == 'invoice.payment_failed'
      subscriber.stripe_events << subscriber.stripe_events.new(event_details: event)
      subscriber.stripe_payment_id = nil
      subscriber.stripe_payment_failed_reason = nil

      if event.data.object.billing_reason == "subscription_cycle"
        subscriber.plan_id = Plan.free_business.first.id
        AutomationMailer.send_email_plan_downgrade(subscriber, event).deliver_now
        Rails.logger.info "==== Plan Downgraded --> #{ subscriber.inspect } ====="
      end

      subscriber.save
      Rails.logger.info "==== Plan Invoice payment Failed #{ subscriber.inspect }"
    end
    Rails.logger.warn "********************************************** #{event.inspect}"

    head :ok
  rescue => e
    Rails.logger.warn "************************************************************"
    Rails.logger.warn "========= Stripe Webhook Error: #{e.inspect} ==============="
    Rails.logger.warn "************************************************************"
  end
end

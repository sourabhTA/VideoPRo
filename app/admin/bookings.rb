ActiveAdmin.register Booking do
  includes :user

  actions :all, except: [:new, :create, :edit, :update, :destroy]
  config.per_page = 30

  controller do
    def find_resource
      Booking.find_by!(slug: params[:id])
    end
  end

  member_action :download_archive, method: [:get] do
    booking = Booking.find(params[:id])
    download_url = SignedUrlAdapter.new(archive_id: booking.archive_id, download_name: booking.download_name).signed_url
    if download_url
      redirect_to download_url
    else
      flash[:alert] = "We could not find that archive."
      redirect_to admin_bookings_path
    end
  end

  index do
    selectable_column
    column :user
    column :booking_date do |booking|
      booking.admin_time.strftime("%m/%d/%Y")
    end
    column :booking_time do |booking|
      booking.admin_time.strftime("%I:%M %p %Z")
    end
    column :time_used do |booking|
      Time.at(booking.time_used).utc.strftime("%H:%M:%S")
    end
    actions do |booking|
      if booking.archive_id.present? && booking.time_used > 0
        link_to_i "download", "Download", download_archive_admin_booking_path(booking.id), class: "btn btn-default"
      end
    end
  end

  show do |booking|
    attributes_table do
      transactions = booking.payment_transactions.order(:created_at)
      booking_transaction_record = transactions.first
      extended_time_transactions = transactions.drop(1)

      extended_minutes_text = ""
      extended_time_transactions.each_with_index do |trans, index|
        extended_minutes_text << "#{index != 0 ? "," : ""} #{trans.call_time_booked/60 } minutes"
      end

      row :booking_time do
        booking.admin_time.strftime("%I:%M %p %Z")
      end

      row :pre_booked_minutes do
        booking_transaction_record.present? ? "#{ booking_transaction_record.call_time_booked/60 } minutes" : "0 minutes"
      end

      row :extended_times do
         extended_minutes_text.present? ? extended_minutes_text : "No time was extended"
      end
    end

    h3 "Payments"
    table_for booking.payment_transactions.order(:created_at), class: "table table-striped" do
      column "Received On", :created_at
      column("Paid Amount") { |p| number_to_currency(p.amount || 0) }
      column("Customer Share") { |p| number_to_currency(p.customer_amount || 0) }
      column("VCAP Share") { |p| number_to_currency( p.VCAP_share || 0) }
      column("Time Used") {|p| Time.at(p.time_used).utc.strftime('%H:%M:%S') }
      column("Total Captured") { |p| number_to_currency( (p.amount_captured).to_f/100 || 0) }
      column("Refund Amount") { |p| number_to_currency(p.amount_refund || 0) }
      column("Stripe Fee") { |p| number_to_currency(p.stripe_fee || 0) }
      # column("Application Fee") { |p| number_to_currency(p.application_fee || 0) }
      # column "Code", :transaction_code
      column "Status", :transaction_status
    end

    default_main_content
  end

  filter :booking_time
end

class BankAccountsController < AuthenticatedController
  def index
    @bank_accounts = if current_user.stripe_custom_account_id.blank?
      []
    else
      Stripe::Account.list_external_accounts(current_user.stripe_custom_account_id, {limit: 100, object: "bank_account"})
    end
    @bookings = current_user.bookings.includes(:payment_transactions)
    if current_user.stripe_custom_account_id
      @payouts = Stripe::Payout.list({}, {'stripe_account': current_user.stripe_custom_account_id})
    end
  end

  def remove
    @bank_account = current_user.bank_accounts.find_by_stripe_bank_account_id(params[:bank_account_id])
    if @bank_account.delete_local_and_stripe
      redirect_to bank_accounts_path, notice: "Bank Account Deleted successfully!"
    else
      render :new, alert: "Bank Account was not deleted successfully!"
    end
  rescue Stripe::InvalidRequestError => e
    redirect_to bank_accounts_path, alert: e.message
  end

  def change_default
    Stripe::Account.update_external_account(current_user.stripe_custom_account_id, params[:bank_account_id],
      {default_for_currency: true})
    redirect_to bank_accounts_path, notice: "Default Account Changed successfully!"
  rescue Stripe::InvalidRequestError => e
    redirect_to bank_accounts_path, alert: e.message
  end

  def new
    @bank_account = BankAccount.new
  end

  def connect_account_edit
    if current_user.stripe_custom_account_id.blank?
      redirect_to(root_path, alert: "Your connect account doesn't exist.") && return
    else
      @connect_account = Stripe::Account.retrieve(current_user.stripe_custom_account_id)
    end
  end

  def connect_account_update
    begin
      year = params[:date][:"of_birth(1i)"].to_i
      month = params[:date][:"of_birth(2i)"].to_i
      day = params[:date][:"of_birth(3i)"].to_i

      Stripe::Account.update(current_user.stripe_custom_account_id,
        {"individual[dob][day]" => day,
         "individual[dob][month]" => month,
         "individual[dob][year]" => year,
         "individual[address][city]" => params[:city],
         "individual[address][postal_code]" => params[:postal_code],
         "individual[address][state]" => params[:state],
         "individual[address][line1]" => params[:address_line_1],
         "individual[ssn_last_4]" => params[:ssn],
         "company[tax_id]" => params[:tax_id],
         "individual[phone]" => params[:phone_number]})
    rescue => e
      flash[:alert] = e.message
      render(:connect_account_edit) && return
    end
    redirect_to(root_path, notice: "Your connect account updated, please wait for approval.") && return
  end

  def create
    year = params[:date][:"of_birth(1i)"].to_i
    month = params[:date][:"of_birth(2i)"].to_i
    day = params[:date][:"of_birth(3i)"].to_i

    @bank_account = current_user.bank_accounts.new(bank_account_params)
    if current_user.stripe_custom_account_id.blank?
      begin
        if params[:country] == "US"
          account = Stripe::Account.create({:country => "US", :type => "custom", :requested_capabilities => ["platform_payments", "card_payments"],
                                            "business_type" => "individual",
                                            "individual[first_name]" => params[:first_name],
                                            "individual[last_name]" => params[:last_name],
                                            "business_profile[url]" => params[:business_url],
                                            "individual[dob][day]" => day,
                                            "individual[dob][month]" => month,
                                            "individual[dob][year]" => year,
                                            "individual[address][city]" => params[:city],
                                            "individual[address][postal_code]" => params[:postal_code],
                                            "individual[address][state]" => params[:state],
                                            "individual[address][line1]" => params[:address_line_1],
                                            "individual[ssn_last_4]" => params[:ssn],
                                            "company[tax_id]" => params[:tax_id],
                                            "individual[email]" => current_user.email,
                                            "individual[phone]" => params[:phone_number],
                                            "business_profile[mcc]" => 5932})
          current_user.stripe_custom_account_id = account.id
        else
          account = Stripe::Account.create({:country => params[:country], :type => "custom",
                                            "business_type" => "individual",
                                            "individual[first_name]" => params[:first_name],
                                            "individual[last_name]" => params[:last_name],
                                            "business_profile[url]" => params[:business_url],
                                            "individual[dob][day]" => day,
                                            "individual[dob][month]" => month,
                                            "individual[dob][year]" => year,
                                            "individual[address][city]" => params[:city],
                                            "individual[address][postal_code]" => params[:postal_code],
                                            "individual[address][state]" => params[:state],
                                            "individual[address][line1]" => params[:address_line_1],
                                            "individual[ssn_last_4]" => params[:ssn],
                                            "company[tax_id]" => params[:tax_id],
                                            "individual[email]" => current_user.email,
                                            "individual[phone]" => params[:phone_number],
                                            "business_profile[mcc]" => 5932})
          current_user.stripe_custom_account_id = account.id
        end

        current_user.save

        if current_user.stripe_custom_account_id.present?
          Stripe::Account.update(current_user.stripe_custom_account_id,
            {
              tos_acceptance: {
                date: Time.now.to_i,
                ip: request.remote_ip
              }
            })
          bank_account = Stripe::Account.create_external_account(
            current_user.stripe_custom_account_id,
            external_account: {object: "bank_account", account_number: params[:bank_account][:account_number],
                               country: params[:bank_account][:country], currency: "USD", account_holder_name: params[:bank_account][:account_holder_name],
                               account_holder_type: params[:bank_account][:account_holder_type], routing_number: params[:bank_account][:routing_number]}
          )
          @bank_account.stripe_bank_account_id = bank_account.id
          @bank_account.save
        end
      rescue Stripe::InvalidRequestError => e
        @error = e.message
        flash[:alert] = @error
        return respond_to do |format|
          format.html {render :new}
          format.js { render layout: false, message: @error, content_type: 'text/javascript' }
        end
      end
    else
      begin
        bank_account = Stripe::Account.create_external_account(
          current_user.stripe_custom_account_id,
          external_account: {object: "bank_account", account_number: params[:bank_account][:account_number],
                             country: params[:bank_account][:country], currency: "USD", account_holder_name: params[:bank_account][:account_holder_name],
                             account_holder_type: params[:bank_account][:account_holder_type], routing_number: params[:bank_account][:routing_number]}
        )
        @bank_account.stripe_bank_account_id = bank_account.id
        @bank_account.save
      rescue Exception => e
        @error = e.message
        flash[:alert] = @error
        return respond_to do |format|
          format.html {render :new}
          format.js { render layout: false, message: @error, content_type: 'text/javascript' }
        end
      end
    end
    return respond_to do |format|
      format.html {redirect_to bank_accounts_path, notice: "Bank Account Saved successfully!"}
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  def destroy
    @bank_account = current_user.bank_accounts.find(params[:id])
    if @bank_account.delete_local_and_stripe
      redirect_to bank_accounts_path, notice: "Bank Account Deleted successfully!"
    else
      render :new, alert: "Bank Account was not deleted successfully!"
    end
  end

  protected

  def bank_account_params
    accessible = [:account_number, :country, :currency, :account_holder_name, :account_holder_type, :routing_number]
    params.require(:bank_account).permit(accessible)
  end
end

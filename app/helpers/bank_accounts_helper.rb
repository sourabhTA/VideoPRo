module BankAccountsHelper
  def custom_account_status(user)
    unless user.stripe_custom_account_id.blank?
      stripe_account_id = user.stripe_custom_account_id
      stripe_account = Stripe::Account.retrieve(stripe_account_id)
      if stripe_account.charges_enabled == true
        user.update_attribute("stripe_account_status", "approved")
      else
        user.update_attribute("stripe_account_status", "pending")
      end
    end
    [user.stripe_account_status, stripe_account]
  end

  def get_charge_amount(transaction)
    charge = Stripe::Charge.retrieve(transaction.transaction_code)
    if charge.status == "succeeded"
      charge.amount.to_f / 100
    else
      0
    end
  end

  def get_pending_account_balance(stripe_account_id)
    if stripe_account_id.blank?
      0
    else
      stripe_balance = Stripe::Balance.retrieve({stripe_account: stripe_account_id})
      stripe_balance.pending[0].amount.to_f / 100
    end
  end

  def get_available_account_balance(stripe_account_id)
    if stripe_account_id.blank?
      0
    else
      stripe_balance = Stripe::Balance.retrieve({stripe_account: stripe_account_id})
      stripe_balance.available[0].amount.to_f / 100
    end
  end

  def get_bank_account(stripe_account_id, bank_account_id)
    account = Stripe::Account.retrieve(stripe_account_id)
    account.external_accounts.retrieve(bank_account_id)
  end
end

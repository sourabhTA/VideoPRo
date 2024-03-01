class BankAccount < ApplicationRecord
  belongs_to :user, optional: true

  def save_local_and_stripe(user)
    begin

      save!
    rescue => e
      errors.add :base, e.message
      false
    end
  end

  def delete_local_and_stripe
    begin
      Stripe::Account.delete_external_account(
        user.stripe_custom_account_id,
        stripe_bank_account_id
      )
      destroy!
    rescue => e
      errors.add :base, e.message
      false
    end
  end

end

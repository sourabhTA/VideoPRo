class CreateBankAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :bank_accounts do |t|
      t.integer :user_id
      t.string :account_number
      t.string :country
      t.string :currency
      t.string :account_holder_name
      t.string :account_holder_type
      t.string :routing_number
      t.string :stripe_bank_account_id

      t.timestamps
    end
  end
end

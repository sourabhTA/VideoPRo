class CreateAppSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :app_settings do |t|
      t.decimal :direct_deposit_fee
      t.decimal :target_to_receive_funds
      t.decimal :pro_commission
      t.decimal :business_commission

      t.timestamps
    end
  end
end

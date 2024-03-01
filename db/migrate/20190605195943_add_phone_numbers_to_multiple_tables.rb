class AddPhoneNumbersToMultipleTables < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :business_number, :string
    add_column :video_chats, :phone_number, :string
  end
end

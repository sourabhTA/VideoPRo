class AddFinishChatDelayjobIdToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :finish_chat_delayjob_id, :integer
  end
end

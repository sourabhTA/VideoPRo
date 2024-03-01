class IsCallEndedToVideochatsAndBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :video_chats, :is_call_ended, :boolean, default: false
    add_column :bookings, :is_call_ended, :boolean, default: false
  end
end

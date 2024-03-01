class CreateStripeEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :stripe_events do |t|
      t.integer :user_id
      t.jsonb :event_details

      t.timestamps
    end
  end
end

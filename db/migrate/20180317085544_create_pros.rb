class CreatePros < ActiveRecord::Migration[5.1]
  def change
    create_table :pros do |t|
      t.string :category_id
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :picture
      t.text :bio
      t.string :phone_number
      t.boolean :is_monday_on, default: true
      t.boolean :is_tuesday_on, default: true
      t.boolean :is_wednesday_on, default: true
      t.boolean :is_thursday_on, default: true
      t.boolean :is_friday_on, default: true
      t.boolean :is_saturday_on, default: false
      t.boolean :is_sunday_on, default: false
      t.time :monday_start_time, default: '9:00 am'
      t.time :monday_end_time, default: '6:00 pm'
      t.time :tuesday_start_time, default: '9:00 am'
      t.time :tuesday_end_time, default: '6:00 pm'
      t.time :wednesday_start_time, default: '9:00 am'
      t.time :wednesday_end_time, default: '6:00 pm'
      t.time :thursday_start_time, default: '9:00 am'
      t.time :thursday_end_time, default: '6:00 pm'
      t.time :friday_start_time, default: '9:00 am'
      t.time :friday_end_time, default: '6:00 pm'
      t.time :saturday_start_time, default: '9:00 am'
      t.time :saturday_end_time, default: '6:00 pm'
      t.time :sunday_start_time, default: '9:00 am'
      t.time :sunday_end_time, default: '6:00 pm'
      t.timestamps
    end
  end
end

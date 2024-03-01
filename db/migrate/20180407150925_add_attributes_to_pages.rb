class AddAttributesToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :header_logo, :string
    add_column :pages, :sub_header_text, :text
    add_column :pages, :sub_header_background_image, :string

    add_column :pages, :sub_header_logos_require, :boolean, default: false
    add_column :pages, :sub_header_logo1, :string
    add_column :pages, :sub_header_logo2, :string
    add_column :pages, :sub_header_logo3, :string
    add_column :pages, :sub_header_logo4, :string
    add_column :pages, :sub_header_logo5, :string
    add_column :pages, :sub_header_logo6, :string

    add_column :pages, :main_steps_require, :boolean, default: false
    add_column :pages, :step1_image, :string
    add_column :pages, :step2_image, :string
    add_column :pages, :step3_image, :string

    add_column :pages, :step1_caption, :string
    add_column :pages, :step2_caption, :string
    add_column :pages, :step3_caption, :string

    add_column :pages, :main_details, :text

    add_column :pages, :save_money, :text
    add_column :pages, :save_time, :text
    add_column :pages, :new_skill, :text
    add_column :pages, :no_stranger, :text

    add_column :pages, :booking_step1_image, :string
    add_column :pages, :booking_step1_caption, :string
    add_column :pages, :booking_step2_image, :string
    add_column :pages, :booking_step2_caption, :string
    add_column :pages, :booking_step3_image, :string
    add_column :pages, :booking_step3_caption, :string

    add_column :pages, :booking_step2_details, :text
    add_column :pages, :booking_step3_details, :text

    add_column :pages, :video_title, :string
    add_column :pages, :video_url, :string

  end
end

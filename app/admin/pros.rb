ActiveAdmin.register Pro do
  menu false
  permit_params :email, :first_name, :last_name, :bio, :picture, :phone_number, :category_id,
    :is_monday_on, :is_tuesday_on, :is_wednesday_on, :is_thursday_on, :is_friday_on,
    :is_saturday_on, :is_sunday_on, :monday_start_time, :monday_end_time, :tuesday_start_time,
    :tuesday_end_time, :wednesday_start_time, :wednesday_end_time, :thursday_start_time, :thursday_end_time,
    :friday_start_time, :friday_end_time, :saturday_start_time, :saturday_end_time, :sunday_start_time,
    :sunday_end_time, :monday_break_start_time, :monday_break_end_time, :tuesday_break_start_time,
    :tuesday_break_end_time, :wednesday_break_start_time, :wednesday_break_end_time, :thursday_break_start_time,
    :thursday_break_end_time, :friday_break_start_time, :friday_break_end_time, :saturday_break_start_time,
    :saturday_break_end_time, :sunday_break_start_time, :sunday_break_end_time

  index do
    selectable_column
    column "Picture" do |pro|
      image_tag pro.picture.url(:small_thumb), class: "small_image" unless pro.picture.blank?
    end
    column :email
    column :first_name
    column :last_name
    column :phone_number
    column :category
    actions
  end

  filter :email
  filter :first_name
  filter :last_name

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "Personal Details" do
      f.input :category_id, as: :select, collection: Category.all.map { |p| [p.name, p.id] }, prompt: "Select Category"
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :picture
      f.input :phone_number
      f.input :bio, as: :text
    end
    f.inputs "Active Days" do
      f.input :is_monday_on, wrapper_html: {class: "fl"}
      f.input :is_tuesday_on, wrapper_html: {class: "fl"}
      f.input :is_wednesday_on, wrapper_html: {class: "fl"}
      f.input :is_thursday_on, wrapper_html: {class: "fl"}
      f.input :is_friday_on, wrapper_html: {class: "fl"}
      f.input :is_saturday_on, wrapper_html: {class: "fl"}
      f.input :is_sunday_on, wrapper_html: {class: "fl"}
    end
    f.inputs "Start Timings" do
      f.input :monday_start_time, label: "Monday", ampm: true, wrapper_html: {class: "fl"}
      f.input :tuesday_start_time, label: "Tuesday", ampm: true, wrapper_html: {class: "fl"}
      f.input :wednesday_start_time, label: "Wednesday", ampm: true, wrapper_html: {class: "fl"}
      f.input :thursday_start_time, label: "Thursday", ampm: true, wrapper_html: {class: "fl"}
      f.input :friday_start_time, label: "Friday", ampm: true, wrapper_html: {class: "fl"}
      f.input :saturday_start_time, label: "Saturday", ampm: true, wrapper_html: {class: "fl"}
      f.input :sunday_start_time, label: "Sunday", ampm: true, wrapper_html: {class: "fl"}
    end

    f.inputs "End Timings" do
      f.input :monday_end_time, label: "Monday", ampm: true, wrapper_html: {class: "fl"}
      f.input :tuesday_end_time, label: "Tuesday", ampm: true, wrapper_html: {class: "fl"}
      f.input :wednesday_end_time, label: "Wednesday", ampm: true, wrapper_html: {class: "fl"}
      f.input :thursday_end_time, label: "Thursday", ampm: true, wrapper_html: {class: "fl"}
      f.input :friday_end_time, label: "Friday", ampm: true, wrapper_html: {class: "fl"}
      f.input :saturday_end_time, label: "Saturday", ampm: true, wrapper_html: {class: "fl"}
      f.input :sunday_end_time, label: "Sunday", ampm: true, wrapper_html: {class: "fl"}
    end

    f.inputs "Break Start Timings" do
      f.input :monday_break_start_time, label: "Monday", ampm: true, wrapper_html: {class: "fl"}
      f.input :tuesday_break_start_time, label: "Tuesday", ampm: true, wrapper_html: {class: "fl"}
      f.input :wednesday_break_start_time, label: "Wednesday", ampm: true, wrapper_html: {class: "fl"}
      f.input :thursday_break_start_time, label: "Thursday", ampm: true, wrapper_html: {class: "fl"}
      f.input :friday_break_start_time, label: "Friday", ampm: true, wrapper_html: {class: "fl"}
      f.input :saturday_break_start_time, label: "Saturday", ampm: true, wrapper_html: {class: "fl"}
      f.input :sunday_break_start_time, label: "Sunday", ampm: true, wrapper_html: {class: "fl"}
    end

    f.inputs "Break End Timings" do
      f.input :monday_break_end_time, label: "Monday", ampm: true, wrapper_html: {class: "fl"}
      f.input :tuesday_break_end_time, label: "Tuesday", ampm: true, wrapper_html: {class: "fl"}
      f.input :wednesday_break_end_time, label: "Wednesday", ampm: true, wrapper_html: {class: "fl"}
      f.input :thursday_break_end_time, label: "Thursday", ampm: true, wrapper_html: {class: "fl"}
      f.input :friday_break_end_time, label: "Friday", ampm: true, wrapper_html: {class: "fl"}
      f.input :saturday_break_end_time, label: "Saturday", ampm: true, wrapper_html: {class: "fl"}
      f.input :sunday_break_end_time, label: "Sunday", ampm: true, wrapper_html: {class: "fl"}
    end
    f.actions
  end

  show do
    panel "Personal Information" do
      table_for pro do
        column :category
        column :email
        column :first_name
        column :last_name
        column :bio
        column :phone_number
      end
    end

    panel "Active Days" do
      table_for pro do
        column :is_monday_on
        column :is_tuesday_on
        column :is_wednesday_on
        column :is_thursday_on
        column :is_friday_on
        column :is_saturday_on
        column :is_sunday_on
      end
    end

    panel "Start Timings" do
      table_for pro do
        column :monday_start_time do |pro|
          pro.monday_start_time.strftime("%I:%M %p")
        end

        column :tuesday_start_time do |pro|
          pro.tuesday_start_time.strftime("%I:%M %p")
        end

        column :wednesday_start_time do |pro|
          pro.wednesday_start_time.strftime("%I:%M %p")
        end

        column :thursday_start_time do |pro|
          pro.thursday_start_time.strftime("%I:%M %p")
        end

        column :friday_start_time do |pro|
          pro.friday_start_time.strftime("%I:%M %p")
        end

        column :saturday_start_time do |pro|
          pro.saturday_start_time.strftime("%I:%M %p")
        end

        column :sunday_start_time do |pro|
          pro.sunday_start_time.strftime("%I:%M %p")
        end
      end
    end

    panel "End Timings" do
      table_for pro do
        column :monday_end_time do |pro|
          pro.monday_end_time.strftime("%I:%M %p")
        end

        column :tuesday_end_time do |pro|
          pro.tuesday_end_time.strftime("%I:%M %p")
        end

        column :wednesday_end_time do |pro|
          pro.wednesday_end_time.strftime("%I:%M %p")
        end

        column :thursday_end_time do |pro|
          pro.thursday_end_time.strftime("%I:%M %p")
        end

        column :friday_end_time do |pro|
          pro.friday_end_time.strftime("%I:%M %p")
        end

        column :saturday_end_time do |pro|
          pro.saturday_end_time.strftime("%I:%M %p")
        end

        column :sunday_end_time do |pro|
          pro.sunday_end_time.strftime("%I:%M %p")
        end
      end
    end

    panel "Break Start Timings" do
      table_for pro do
        column :monday_break_start_time do |pro|
          pro.monday_break_start_time.strftime("%I:%M %p")
        end

        column :tuesday_break_start_time do |pro|
          pro.tuesday_break_start_time.strftime("%I:%M %p")
        end

        column :wednesday_break_start_time do |pro|
          pro.wednesday_break_start_time.strftime("%I:%M %p")
        end

        column :thursday_break_start_time do |pro|
          pro.thursday_break_start_time.strftime("%I:%M %p")
        end

        column :friday_break_start_time do |pro|
          pro.friday_break_start_time.strftime("%I:%M %p")
        end

        column :saturday_break_start_time do |pro|
          pro.saturday_break_start_time.strftime("%I:%M %p")
        end

        column :sunday_break_start_time do |pro|
          pro.sunday_break_start_time.strftime("%I:%M %p")
        end
      end
    end

    panel "Break End Timings" do
      table_for pro do
        column :monday_break_end_time do |pro|
          pro.monday_break_end_time.strftime("%I:%M %p")
        end

        column :tuesday_break_end_time do |pro|
          pro.tuesday_break_end_time.strftime("%I:%M %p")
        end

        column :wednesday_break_end_time do |pro|
          pro.wednesday_break_end_time.strftime("%I:%M %p")
        end

        column :thursday_break_end_time do |pro|
          pro.thursday_break_end_time.strftime("%I:%M %p")
        end

        column :friday_break_end_time do |pro|
          pro.friday_break_end_time.strftime("%I:%M %p")
        end

        column :saturday_break_end_time do |pro|
          pro.saturday_break_end_time.strftime("%I:%M %p")
        end

        column :sunday_break_end_time do |pro|
          pro.sunday_break_end_time.strftime("%I:%M %p")
        end
      end
    end

    # active_admin_comments
  end
end

ActiveAdmin.register AdminVideoChat do
  actions :index, :new, :create, :edit, :destroy, :update
  permit_params :name, :session_id, :email, :subject, :body
  config.filters = false

  form html: {autocomplete: "off"} do |f|
    f.inputs do
      f.input :name
      f.input :email, input_html: {placeholder: "Please add email address/s separated with semicolon.", autocomplete: "nope"}
      f.input :subject, input_html: {value: "Video Chat Link", autocomplete: "nope"}
      f.input :body, input_html: {value: "Click on the link below to join the Video Chat a Pro Session.", autocomplete: "nope"}
    end
    f.actions
  end

  member_action :email_link, method: [:get, :post] do
    if request.post?
      BookingMailer.send_videochat_link_from_admin(resource).deliver_now
      flash[:notice] = "Email Sent successfully!"
      redirect_to admin_admin_video_chats_path
    end
  end

  index do
    selectable_column
    column :name
    column "Admin URL" do |admin_video_chat|
      link_to "Open Video Chat", chat_path(admin_video_chat.professional_token), target: :_blank
    end
    column "User URL" do |admin_video_chat|
      link_to "Link for #{admin_video_chat.name}", chat_path(admin_video_chat.client_token), target: :_blank
    end
    actions do |admin_video_chat|
      link_to "Email_link", email_link_admin_admin_video_chat_path(admin_video_chat)
    end
  end
end

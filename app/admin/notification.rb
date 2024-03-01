ActiveAdmin.register Notification do
  actions :all, except: [:edit, :update]
  permit_params :title, :message, :to_id, :user_group

  form do |f|
    f.inputs do
      f.input :title, input_html: {required: true}
      f.input :message, input_html: {required: true}
      f.input :to_id, label: "Send To User", as: :select, collection: User.all.map { |p| [p.email, p.id] }, prompt: "Select User"
      f.input :user_group, label: "Select User Group", as: :select, collection: [["All Users","All"],["Pro Users","Pro"],["Business Users","Business"]], prompt: "Select Group User"
    end
    f.actions
  end

  index do
    column :title
    column :message
    column "To User", :to_id
    column :user_group
    column :chat_time
    column :from_id
    column :videochat_id
    column :booking_id

    actions
  end
end

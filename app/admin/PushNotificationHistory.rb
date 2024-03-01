ActiveAdmin.register PushNotificationHistory do
   menu label: "Push Notification History"
   # permit_params :message_body, :title, :user_type
   actions :all, except: [:new, :create, :edit, :destroy]


   index do
    column :title
    column :message_body
    column :user_type
    column :time_zone
    column :created_at
    column :run_at_time
    actions
   end
   

end
ActiveAdmin.register PushNotificationModule do
  menu label: "Push Notification"
  # batch_action :destroy, confirm: "Are you sure??" do |ids|
  # config.batch_actions = false
   # permit_params :message_body, :title, :user_type  , except: [:new, :create]
  permit_params :message_body, :title, :user_type,  :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :run_at_time, :slug
  actions :all
    # RESTRICTED_ACTIONS = ["destroy"], except: [:destroy]
# @slug = PushNotificationModule.all
#         $push_notification = PushNotificationModule.first
#          $val=0
# #      PushNotificationModule.all.each do|pnm|
#       controller do
         
#         def action_methods
#           # if PushNotificationModule.first.id==18
#           #    super  - ['destroy']
#           #  else 
#           #   super
#           #  end
#           # PushNotificationModule.all.each do|pnm|
#           #   if pnm.slug.blank?
#           #   if (pnm.slug=="reminder_notification" &&  @pnm_notification&.slug!=nil)
             
#           #   debugger
#             # PushNotificationModule.all.each do|pnm| 
#             #   if pnm.slug =="reminder_notification" && pnm.user_type == "pro"
#             if $val==0
#             if $push_notification.slug=="reminder_notification" && $push_notification.user_type == "pro"
#                  $val=1
#               end
#               super  - ['destroy']
#             end
#         end

          # if $val==1
          #   break
          # end
     # end
     # end


   # controller do
   #             # puts resource.inspect

   #   def action_methods
   #     if PushNotificationModule.find_by_slug("reminder_notification").present?
   #        super - RESTRICTED_ACTIONS
   #     else
   #       super
   #     end
   #   end
   # end

   
   # controller do
   #   def action_methods
   #     # if PushNotificationModule.where("slug = ?","reminder_notification")
   #     if PushNotificationModule.slug=="reminder_notification"
   #       puts("hello")
   #        super - ['destroy']
   #     else
   #       puts("welcome")
   #       super
   #     end
   #   end
   # end


   # controller do
   #   def action_methods
   #     # if PushNotificationModule.where("slug = ?","reminder_notification")
   #       if $push_notification.slug=="reminder_notification"
   #         super  - ['destroy']         
   #     elsif $push_notification.slug!=nil
   #       super
   #     else 
   #       super
   #     end
   #   end
   # end   




 # controller do
 #   def action_methods
 #     if PushNotificationModule.slug == "reminder_notification"
 #       # if pnm.slug=="reminder_notification"
 #         super - ['destroy']

 #     else
 #       super
 #     end
 #   end
 # end
  

   # controller do
   #   def action_methods
   #     slug = PushNotificationModule.where("slug = ?","reminder_notification")
   #       if slug.blank?
   #         puts("hello")
   #         super          
   #     else
   #       puts("hi")
   #       super - ['destroy']
   #       break
   #     end
   #   end
   # end   

   # controller do
   #   def action_methods
   #     # debugger
   #      PushNotificationModule.where("slug = ?","reminder_notification") ? super-['destroy'] : super
   #     # $push_notification.slug=="reminder_notification" ? super-['destroy'] : super
   #     # if $push_notification.slug.present?
   #     #   break
   #     # end
   #   end
   # end   

   # controller do
   #   def destroy
   #     super - ['destroy']
   #   end
   # end


  
  index do
   column :title
   column :message_body
   column :user_type
    actions

#     column :actions do |item|
#   links = []
#   links << link_to('Show', admin_push_notification_module(item))
#   links << link_to('Edit', edit_admin_push_notification_module_path(item))
#   links << link_to('Delete', admin_push_notification_module_path(item), method: :delete, confirm: 'Are you sure?')
#   links.join(' ').html_safe
# end
   # actions do |v|
     # controller do
     # if controller.action_methods.include?("destroy")
    #    if v.object.slug=="reminder_notification"
    #      super - ['destroy']
    #    else
    #      super
    #    end
    #   # end
    # end
  end

  form do |f|
    f.inputs do
      #  byebug
      #  f.input :title, input_html: {disabled: f.object && f.object.slug && f.object.slug=="reminder_notification"}
       f.input :title, input_html: {}
       f.input :message_body, input_html: {required: true}
       # f.input :slug, input_html: {disabled: f.object.slug=="reminder_notification"}
       # f.input :user_type, label: "Select User Group", as: :select, collection: [["Pro Users","Pro"],["All Users","All"],["Business Users","Business"]], prompt: "Select Group User", input_html: {disabled: true}
      #  f.input :user_type, label: "Select User Group", as: :select, collection: [["Pro Users","pro"],["Business Users","business"],["Employee Users","employee"],["Client","client"]], prompt: "Select Group User", input_html:{disabled: f.object && f.object.slug && f.object.slug=="reminder_notification"}
       f.input :user_type, label: "Select User Group", as: :select, collection: [["Pro Users","pro"],["Business Users","business"],["Employee Users","employee"],["Client","client"]], prompt: "Select Group User", input_html:{}
        
       f.label "Monday"
       f.check_box :monday, :style => "margin: 0 23px 0px 9px;"
       f.label "Tuesday"
       f.check_box :tuesday, :style => "margin: 0 23px 0 9px;"
       f.label "Wednesday"
       f.check_box :wednesday, :style => "margin: 0 23px 0 9px;"
       f.label "Thursday"
       f.check_box :thursday, :style => "margin: 0 23px 0 9px;"
       f.label "Friday"
       f.check_box :friday, :style => "margin: 0 23px 0 9px;"
       f.label "Saturday"
       f.check_box :saturday, :style => "margin: 0 23px 0 9px;"
       f.label "Sunday"
       f.check_box :sunday, :style => "margin: 0 23px 25px 9px;"

       f.input :run_at_time, as: :time_picker, timepicker_options: {format: "%H:%M"}, :input_html => {:style=> 'width: 9%; margin: 0 0 40px 0; id: timepicker'}
       
   #f.input :run_at_time, as: "select", collection: time_options_for_select, ampm: true, wrapper_html: {class: "fl"}
    end

    f.actions
    end
end
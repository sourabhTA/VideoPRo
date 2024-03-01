Rails.application.routes.draw do
  comfy_route :cms_admin, path: "/admin/cms"
  devise_for :users, param: :slug, controllers: {
    registrations: "registrations",
    sessions: "sessions",
    confirmations: "confirmations",
    passwords: "passwords"
  }

  devise_scope :user do
    get "/signup" => "registrations#signup", :as => :signup
    # get "/users/sign_up/:role" => "registrations#new", :as => :business_signup
    # get "/users/sign_up/:role" => "registrations#new", :as => :pro_signup
  end

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :api do
    namespace :v1 do
      # API::V1::UserController
      get "/get_token" => "user#get_token", :as => :get_token
      get "/get_user" => "user#get_user", :as => :get_user
      get "/scheduled_chats" => "user#scheduled_chats", :as => :scheduled_chats
      get "/load_more_scheduled_chats" => "user#load_more_scheduled_chats", :as => :load_more_scheduled_chats
      get "/business_videos" => "user#business_videos", :as => :business_videos
      get "/download_chat" => "user#download_chat", :as => :download_chat
      get "/get_leads" => "user#get_leads", :as => :get_leads
      get "/get_lead_detail" => "user#get_lead_detail", :as => :get_lead_detail
      get "/client/client_authentication" => "client#client_authentication", :as => :client_authentication
      get "/client/client_verify_email" => "client#client_verify_email", :as => :client_verify_email
      get "/client/get_client_notification" => "client#get_client_notification", :as => :get_client_notification
      get "/client/get_booking_summary" => "client#get_booking_summary", :as => :get_booking_summary
      get "/client/current_client_app_version" => "client#client_app_version", :as => :client_app_version
      get "/current_user_app_version" => "user#user_app_version", :as => :user_app_version
      post "/client/logout_client" => "client#logout_client", :as => :logout_client
      post "/client/client_fcm_token_update" => "client#client_fcm_token_update", :as => :client_fcm_token_update
      post "/user_update" => "user#user_update", :as => :user_update
      post "/fcm_token_update" => "user#fcm_token_update", :as => :fcm_token_update
      post "/logout_user" => "user#logout_user", :as => :logout_user
      post "/set_availability" => "user#set_availability", :as => :set_availability
      post "/business_image_update" => "user#business_image_update", :as => :business_image_update
      post "/forgot_password" => "user#forgot_password", :as => :forgot_password

      get "/fetch_employees" => "employee#fetch_employees", :as => :fetch_employees

      post "/update_employee_notifications" => "employee#update_employee_notifications", :as => :update_employee_notifications
      post "/create_user_employee" => "employee#create_user_employee", :as => :create_user_employee
      post "/create_video_chat" => "employee#create_video_chat", :as => :create_video_chat

      post "/chats/:id/start" => "chats#start", :as => :start
      post "/chats/:id/client_start" => "chats#client_start", :as => :client_start
      post "/chats/:id/start_clock" => "chats#start_clock", :as => :start_clock
      post "/chats/:id/client_start_clock" => "chats#client_start_clock", :as => :client_start_clock
      post "/chats/:id/sync_clock" => "chats#sync_clock", :as => :sync_clock
      post "/chats/:id/end_chat" => "chats#end_chat", :as => :end_chat
      post "/chats/:id/add_chat_time" => "chats#add_chat_time", :as => :add_chat_time
      post "/chats/:id/add_review" => "chats#add_review", :as => :add_review

      get "/get_earnings" => "bank_accounts#get_earnings", :as => :get_earnings
      get "/chats/:id/get_chat_time" => "chats#get_chat_time", :as => :get_chat_time
      get "/notifications/get_notification" => "notifications#get_notification", :as => :get_notification
      get "/notifications/booking_details" => "notifications#booking_details", :as => :booking_details
      get "/notifications/get_review_details" => "notifications#get_review_details", :as => :get_review_details
      get "/notifications/get_video_chat_summary" => "notifications#get_video_chat_summary", :as => :get_video_chat_summary
      get "/chats/:id/get_review" => "chats#get_review", :as => :get_review
    end

    scope :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        sessions: 'overrides/sessions'
      }
    end
  end

  resources :employees


  resources :profiles, param: :slug do
    resources :contact_us, only: %i[new create]

    member do
      get :claim_business
      post :claim_business
    end
    collection do
      get :tools_to_succeed
      get :availability
    end
  end
  get "/:role/302" => "profiles#error_page_302", :as => :error_page_302
  get "/:slug/reviews" => "profiles#user_reviews", :as => :user_reviews
  get "/reviews(/:slug)" => "reviews#index", :as => :slug_reviews
  # resources :reviews, only: :index

  get "/complete_profile" => "profiles#complete_profile", :as => :complete_profile
  get "/business_complete_profile" => "profiles#business_complete_profile", :as => :business_complete_profile
  get "/profile/getTabData" => "profiles#getTabData", :as => :getTabData
  get "/profile/skip_step" => "profiles#skip_step", :as => :skip_step
  get "/profile/email_download_link" => "profiles#email_download_link", :as => :email_download_link

  get "/profiles/:token/auto_login" => "profiles#auto_login", :as => :auto_login

  resources :claims
  resources :plans
  resources :subscriptions, only: [:index]

  resources :video_chats, only: %i[new create index destroy] do
    member do
      get :send_email
      post :send_email
    end
  end

  resources :bank_accounts do
    collection do
      post "change_default/:bank_account_id" => "bank_accounts#change_default", :as => :change_default
      post "remove/:bank_account_id" => "bank_accounts#remove", :as => :remove
    end
  end
  get "/connect/account/edit" => "bank_accounts#connect_account_edit", :as => :connect_account_edit
  post "/connect/account/update" => "bank_accounts#connect_account_update", :as => :connect_account_update

  resources :scheduled_chats, only: :index

  match "/contact_us" => "contact_us#do_contact", :as => :contact_us, :via => [:get, :post]

  get "/:role(/:trade)" => "search#index", :as => :search_users,
  :constraints => lambda { |request| "diycompany".include?(request.params[:role]) }

  get "/company(/:trade)" => "search#index", :as => :search_company
  get "/diy(/:trade)" => "search#index", :as => :search_diy

  post "/subscription/new" => "subscriptions#new", :as => :new_subscription
  post "/subscription/edit/:slug" => "subscriptions#edit", :as => :edit_subscription
  post "/subscription/update/:slug" => "subscriptions#update", :as => :update_subscription
  get "/subscription/new" => "subscriptions#index"
  post "/subscription/create" => "subscriptions#create", :as => :create_subscription
  post "/stripe/webhooks", to: "stripe#webhooks"
  get "careers/index"

  resources :chats, only: :show do
    member do
      get :download
      get :start
      post :start_clock
      get :sync_clock
      patch :end
      get :get_total_cost
      post :review
      get :review
    end

    collection do
      post :tokbox_callback
    end
  end

  resources :bookings, except: [:new] do
    member do
      get "thankyou"
      get "call_details"
      post "capture_payment"
    end
    collection do
      get "withdraw"
      get "stripe-checkout"
    end
  end
  get "/booking/:slug/new" => "bookings#new", :as => :new_booking
  get "/user_avalibility/:user_id" => "bookings#user_avalibility", :as => :user_avalibility

  get "/blogs(/:category_id)" => "blogs#index", :as => :blogs
  get "/blog/:category_id/:id" => "blogs#show", :as => :blog

  resources :scheduled_services, except: [:new]
  get "/scheduled_services/:slug/new" => "scheduled_services#new", :as => :new_scheduled_service

  get "/fetch_pros" => "bookings#fetch_pros"
  get "/fetch_pro_datetime_slots" => "bookings#fetch_pro_datetime_slots"
  get "/fetch_time_slots_only" => "bookings#fetch_time_slots_only"
  get "/fetch_pro_time_slots" => "bookings#fetch_pro_time_slots"
  get "/terms_and_conditions" => "home#terms_and_conditions"
  get "/emails/unsubscribe/:token" => "home#unsubscribe", :as => :get_unsubscribe
  post "/emails/unsubscribe/:token" => "home#unsubscribe", :as => :post_unsubscribe
  get "/appliance" => "home#appliance"
  get "/tradesman_signup" => "home#tradesman_signup", :as => :new_tradesman_signup
  get "/business_signup" => "home#business_signup", :as => :new_business_signup

  get "/electrical" => "home#categorization"
  get "/hvac" => "home#hvac"
  get "/landscaping" => "home#categorization"
  get "/auto-repair" => "home#categorization"
  get "/plumber" => "home#plumber"
  get "/appliances" => "home#appliance"
  get "/home-improvements" => "home#categorization"

  get "/plumbing-repair-contractors" => "home#categorization"
  get "/plumbing" => "home#categorization"
  get "/electrical-repair-contractors" => "home#categorization"
  get "/electrical" => "home#categorization"
  get "/auto-repair-shops" => "home#categorization"
  get "/hvac-repair-contractors" => "home#categorization"
  get "/appliance-repair-company" => "home#categorization"
  get "/home-improvement-contractors" => "home#catergorization"
  get "/mobile-app/:mobile_app" => "home#get_mobile_app", :as => :mobile_app

  match "/upload/resume" => "home#upload_resume", :as => :upload_resume, :via => [:get, :post]

  get "/careers" => "careers#index"
  get "/faqs" => "faqs#index"

  get "/s/:id" => "shortener/shortened_urls#show", :as => :short
  get "/:slug", to: "profiles#show", as: "show_profile",
  :constraints => lambda { |request| User.readonly.with_deleted.find_by_slug(request.params[:slug]) }

  get "/*slug" => "home#pages", :as => :page,
  :constraints => lambda { |request| File.extname(request.path).empty? }
  # Ensure that this route is defined last
  # comfy_route :cms, path: "/"
  # root to: "comfy/cms/content#show"
  root to: "home#index"
end

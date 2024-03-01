ActiveAdmin.register SmsSetting do
  menu label: "SMS Config"

  actions :all, except: [:create, :new, :destroy, :show]

  config.breadcrumb = false
  config.filters = false
  config.paginate = false

  permit_params :phone_number, :api_key, :api_secret

  controller do
    def edit
      @page_title = "Edit Nexmo SMS Configuration"
    end
  end

  collection_action :test_sms, method: :post do
    test_params = params.require(:sms).permit(:to, :message)
    SmsService::SMSClient.test_sms(to: test_params[:to], text: test_params[:message])

    redirect_to collection_path, notice: "Test SMS sent!"
  end

  index title: "Nexmo SMS Configuration", download_links: false do |a|
    column "Phone Number" do |s|
      s.phone_number
    end
    column "API Key" do |s|
      s.api_key
    end
    column "API Secret" do |s|
      s.api_secret
    end
    actions
  end

  sidebar "Test SMS", only: :index do
    div do
      render partial: "test_sms_form"
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "Nexmo Config" do
      f.input :phone_number, as: :string, input_html: {required: true}
      f.input :api_key, as: :string, input_html: {required: true}
      f.input :api_secret, as: :string, input_html: {required: true}
    end

    f.actions do
      f.action :submit, button_html: {class: "input_action", disable_with: "Wait..."}, label: "Update Config"
      f.action :cancel, as: :link, label: "Cancel"
    end
  end
end

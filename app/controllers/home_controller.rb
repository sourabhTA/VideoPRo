class HomeController < ApplicationController
  before_action :check_required_settings, except: [:index, :categorization, :terms_and_conditions, :upload_resume]
  before_action :load_page_via_cms, only: [:index,:terms_and_conditions,:categorization,:pages,:mechanic,:business_signup,:tradesman_signup,:plumber,:landscaper,:hvac,:electrician,:appliance]

  def upload_resume
    if request.post?
      if verify_recaptcha
        if !params[:resume].nil? && !params[:resume].blank?
          file = params[:resume].path
          file_name = params[:resume].original_filename
        else
          file = ""
          file_name = ""
        end

        GenericMailer.send_resume(params[:name], params[:address], params[:phone],
          params[:email], params[:available], params[:skills],
          params[:job_history], file_name, file).deliver
        redirect_to("/careers", notice: "Your application received!") && return
      else
        render("/home/upload_resume") && return
      end
    end
  end

  def unsubscribe
    @user = User.find_by_token(params[:token])
    if request.post?
      @user = Client.find_by_token(params[:token]) if @user.blank?
      @user&.update(email_subscription: false, unsubscribe_at: DateTime.current)
      redirect_to(root_path, alert: "You are unsubscribed successfully!") && return
    else
      if @user.nil?
        redirect_to(root_path, alert: "User not found!") && return
      end
      render layout: "extra"
    end
  end

  def terms_and_conditions
    load_page_data("terms_and_conditions")
    @exclusive_assets = ['application', 'stripe', 'map']
    @hideMenu = true
    render layout: "extra"
  end

  def index
    load_page_data("home_page")
  end

  def auto_repair
    load_page_data("auto-repair")
    render "main"
  end

  def business_signup
    @hideMenu = true
    load_page_data("business_signup")
    @exclusive_assets = ['application', 'stripe', 'map']
    @role = "business"
    render "main"
  end

  def tradesman_signup
    @hideMenu = true
    load_page_data("tradesman_signup")
    @exclusive_assets = ['application', 'stripe', 'map']
    @role = "pro"
    render "main"
  end

  def categorization
    load_page_data(request.fullpath.split("/")[1])
    render "main"
  end

  def pages
    redirect_to("https://videochatapro.com/video-chat-a-pro", :status => :moved_permanently) and return if params[:slug] == "plumbers-video-chat-a-pro"
    # if Page.find_by(slug: params[:slug]).present?
    #   load_page_data(params[:slug])
    # else
      begin
        parent_page = Comfy::Cms::Page.find_by(slug: request.path.split("/")[1])
      rescue Exception => e
        puts e
        redirect_to(page_path)
        return
      end
    # end
    if @page.blank?
      render file: "#{Rails.root}/public/404.html", layout: false, status: 404
      return
    end
    render "main"
  end

  def plumber
    load_page_data("plumber")
  end

  def landscaping
    load_page_data("landscaper")
  end

  def hvac
    load_page_data("hvac")
  end

  def electrical
    load_page_data("electrician")
  end

  def appliance
    load_page_data("appliance")
  end

  def home_improvements
    load_page_data("home_improvements")
  end

  def get_mobile_app
    if params[:mobile_app].present?
      redirect_to ENV.fetch(params[:mobile_app])
    else
      redirect_to root_path
    end
  rescue => e
    flash[:warning] = "Error: #{e.message}"
  end
end

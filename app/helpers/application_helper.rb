module ApplicationHelper
  CATEGORY_TITLE = {
    "appliances"    => "is Appliance Repair in",
    "landscapers"   => "is Landscaper in",
    "mechanics"     => "is Auto Repair Shop in",
    "hvacs"         => "is AC Repair in",
    "plumbers"      => "is a Plumber in",
    "electricians"  => "is Electrician in",
    "handyman"      => "is Handyman in"
  }

  PRO_CATEGORY_TITLE = {
    "plumbers"      => "pro_first_name is a Plumber",
    "appliances"    => "pro_first_name is an Appliance Repair Technician",
    "electricians"  => "pro_first_name is an Electrician",
    "landscapers"   => "pro_first_name is a Landscaper",
    "hvacs"         => "pro_first_name is an HVAC Repair Technician",
    "mechanics"     => "pro_first_name is an Auto Repair Mechanic",
    "handyman"      => "pro_first_name is a Handyman"
  }

  def button_link(url, text)
    link_to text, url, class: "btn btn-large btn-primary"
  end

  def title(page_title)
    content_for :title, page_title.to_s
  end

  def user_title_tag(category)
    content_for :title, user_title(category)
  end
  def user_title(category)
    return "Video Chat a Pro" if category.blank?
    if @user.pro?
      "#{PRO_CATEGORY_TITLE[category]&.gsub('pro_first_name',@user.first_name)}"
    else
      "#{@user.name} #{CATEGORY_TITLE[category]} #{@user.city} #{@user.state}"
    end
  end

  def resource_name
    :user
  end

  def trackers
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def fake_booking?
    admin_business_user_emails = User.find_by(email: "info@videochatapro.com")&.all_business_users&.map(&:email) || []
    current_user && admin_business_user_emails.include?(current_user.email)
  end

  def free_of_charge
    fake_booking? || user.free_of_charge
  end

  # def embed(youtube_url)
  #   youtube_id = youtube_url.split("=").last
  #   content_tag(:iframe, nil, src: "//www.youtube.com/embed/#{youtube_id}", :allowfullscreen => "", :frameborder => "0", :width => '850', :height => '500')
  # end

  require "net/http"

  # Regex to find YouTube's and Vimeo's video ID
  YOUTUBE_REGEX = %r(^(https*://)?(www.)?(youtube.com|youtu.be)/(watch\?v=){0,1}([a-zA-Z0-9_-]{11}))

  # Finds YouTube's video ID from given URL or [nil] if URL is invalid
  # The video ID matches the RegEx \[a-zA-Z0-9_-]{11}\
  def find_youtube_id url
    url = sanitize url
    matches = YOUTUBE_REGEX.match url.to_str
    if matches
      matches[6] || matches[5]
    end
  end

  # Get YouTube video iframe from given URL
  def get_youtube_iframe url, width, height, alt, title
    youtube_id = find_youtube_id url

    result = %(<iframe alt="#{alt}" title="#{title}" width="#{width}"
                height="#{height}" src="//www.youtube.com/embed/#{youtube_id}"
                frameborder="0" allowfullscreen></iframe>)
    result.html_safe
  end

  # Main function
  # Return a video iframe
  # If the url provided is not a valid YouTube or Vimeo url it returns [nil]
  def embed(url, width = "760px", height = "425px", alt = nil, title = nil)
    if find_youtube_id(url)
      get_youtube_iframe(url, width, height, alt, title)
    end
  end

  def load_profile_url
    current_user.employee? ? show_profile_path(current_user.business) : show_profile_path(current_user)
  end

  def load_active_class(controller_required, action_required)
    controller_name == controller_required && action_required.include?(action_name) ? "active" : ""
  end

  def ninty_percent_off(plan)
    plan.display_price - ((plan.display_price * 90) / 100)
  end

  def footer_social_links
    FooterSocialLink.all
  end

  def load_sub_header_background_image(page)
    page.sub_header_background_image.url
  end

  def load_main_background_image(page)
    page.main_background_image.url
  end

  def category_class(category)
    category.name == params[:trade] ? "active" : ""
  end

  def role_class(help_with, help_for)
    res = "diy" if help_for == "pros"
    res = "company" if help_for == "businesses"
    (help_with == help_for) || (res == request.fullpath.split("/")[1]) ? "active" : ""
  end

  def active_menu_link(icon, controller, actions, text, path)
    active_class = load_active_class(controller, actions)

    link_to path, class: active_class do
      content_tag(:span, nil, class: "fa fa-#{icon} base_color_#{active_class}") +
        " #{text}"
    end
  end

  def link_to_i(icon, text, path, **options)
    link_to path, **options do
      content_tag(:span, nil, class: "fa fa-#{icon}") +
        " #{text}"
    end
  end

  def blog_page_type(params)
    params[:category_id].present? ? "/blog_#{BlogCategory.find_by_slug(params[:category_id]).name.downcase.gsub(' ','_')}" : request.path
  end

  def get_tag_type(path)
    path.split('/').drop(1).join('_')
  end

  def get_meta_tag(page_type, page_no, tag_type="h1_tag")
    @meta_record ||= MultipageMeta.get_meta(page_type, page_no&.to_i||1)
    Rails.logger.info "======= Meta Record not found for page type =====  #{page_type}" if @meta_record.blank?
    return content_for :title, @meta_record&.send('title').to_s if tag_type == "title_blog"
    @meta_record&.send(tag_type)
  end

  def og_meta(tag)
    cms_fragment_content("open_graph_#{tag}").present? ? cms_fragment_content("open_graph_#{tag}"): cms_fragment_content(tag)
  end

  def og_image
    if cms_fragment_content("open_graph_image").present?
      url_for(cms_fragment_content("open_graph_image")&.attachments&.first&.blob)
    else
      asset_path("logo.webp")
    end
  end
end

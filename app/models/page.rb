class Page < ApplicationRecord
  mount_uploader :header_logo, LogoUploader
  mount_uploader :sub_header_logo1, LogoUploader
  mount_uploader :sub_header_logo2, LogoUploader
  mount_uploader :sub_header_logo3, LogoUploader
  mount_uploader :sub_header_logo4, LogoUploader
  mount_uploader :sub_header_logo5, LogoUploader
  mount_uploader :sub_header_logo6, LogoUploader

  mount_uploader :sub_header_background_image, ImageUploader
  mount_uploader :main_background_image, ImageUploader
  mount_uploader :step1_image, ImageUploader
  mount_uploader :step2_image, ImageUploader
  mount_uploader :step3_image, ImageUploader

  mount_uploader :booking_step1_image, ImageUploader
  mount_uploader :booking_step2_image, ImageUploader
  mount_uploader :booking_step3_image, ImageUploader

  SLUG_ALT_MAPPING = {
    "plumbing-do-it-yourself" => "Online platform to get plumbing advice",
    "electrical-do-it-yourself" => "Best site to ask an electrician online",
    "irrigation-do-it-yourself" => "Online platform for your next sprinkler repair diy project",
    "automotive-do-it-yourself" => "Website to get mechanic help online",
    "hvac-do-it-yourself" => "Online platform to get hvac help",
    "appliance-do-it-yourself" => "Website for your do it yourself appliance repair project",
    "plumbing-repair-contractors" => "Website to get plumbing repair services online",
    "electrical-repair-contractors" => "Online platform to ask an electrician for help",
    "hvac-repair-contractors" => "Online platform to find local hvac contractors",
    "appliance-repair-company" => "Online platform to find local appliance repair",
    "tradesman_signup" => "Website for local tradesmen who get paid to help",
    "business_signup" => "Online platform to list your business"
  }

  def alt_title
    SLUG_ALT_MAPPING[slug]
  end

  def home_page_benefits
    [
      save_time,
      save_money,
      new_skill,
      no_stranger
    ].compact
  end

  def self.not_found
    @@not_found_page ||= OpenStruct.new(
      title: "Page Not Found",
      sub_header_text: <<~HTML,
        <style>.test-connection,.video-container{display:none}.hero-inner{min-height: unset}</style>
        <div style='text-align: center; font-size: 22px; font-weight: 100; margin-top: 15px; color: #47494e; margin-bottom: 8px;'>The page you were looking for doesn't exist.</div>
        <p style='text-align:center; -webkit-margin-after: 0px; -webkit-margin-before: 0px; font-size: 15px; color: #7f828b; line-height: 21px; margin-bottom: 4px; '>
          You may have mistyped the address or the page may have moved.
        </p>
      HTML
      sub_header_background_image: OpenStruct.new(url: "icon_error.svg"),
      header_logo: OpenStruct.new(url: "logo.jpg"),
      shop_button_text: "Go to home page"
    )
  end
end

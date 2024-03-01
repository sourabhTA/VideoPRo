require "nokogiri"
require "open-uri"

namespace :scraper do
  desc "Yellow Pages Crawler"
  task start_crawling: :environment do
    puts "STARTING ...."
    # "https://www.yellowpages.com/search?search_terms=Electricians&geo_location_terms=CA"
    scrapped_links = ["https://www.yellowpages.com/search?search_terms=Landscape+Contractors&geo_location_terms=alaska"]
    scrapped_links.each do |link|
      base_uri = link
      page = 1

      while business_links.present?
        begin
          uri = base_uri + "&page=#{page}"
          puts "-------------------------------------------------------------------"
          puts uri
          user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
          @page = Nokogiri::HTML(URI.parse(uri).open("User-Agent" => user_agent))
          business_links = @page.css(".business-name").map { |a| a.attr("href") }

          puts business_links.count

          unless business_links.blank?
            business_links.each_with_index do |business_url, index|
              complete_url = "https://www.yellowpages.com#{business_url}"
              user = User.find_by_scrapped_link(complete_url)
              if user.nil?
                save_business_information(complete_url, index)
              else
                puts "**********************SKIPPED(#{index})****************************"
              end
            end
          end

          page += 1
        rescue => e
          page += 1
          puts "Error MAIN PAGE: =====>>>>> #{e.inspect}"
        end
      end
    end
  end

  def save_business_information(business_url, index)
    # business_url = "https://www.yellowpages.com/san-antonio-tx/mip/chambliss-plumbing-company-470963235?lid=405396962"

    business_page = Nokogiri::HTML(URI.parse(business_url).open)
    puts "==========================================================>>>#{index}"
    puts business_url
    # business_url = "https://www.yellowpages.com/san-antonio-tx/mip/jrs-plumbing-18120835?lid=1000119746488"
    unless business_url.blank?
      user = User.new
      user.agree_to_terms_and_service = true
      user.role = :business
      user.scrapped_link = business_url
      user.confirmed_at = DateTime.now

      description = business_page.css(".general-info").text
      user.description = if description.blank?
        business_page.css(".slogan").text
      else
        description
      end

      specialties = business_page.css(".general-info").first.try(:next_element).try(:next_element).try(:next_element).try(:next_element).try(:text)
      user.specialties = if specialties.blank?
        business_page.css(".categories").last.text
      else
        specialties
      end

      user.product_knowledge = business_page.css(".brands").text
      user.name = business_page.css(".sales-info").css("h1").text
      user.address = business_page.css(".contact .address").text
      user.business_number = business_page.css(".phone").text
      user.phone_number = business_page.css(".phone").text
      user.business_website = business_page.css(".website-link").try(:attr, "href").try(:value)

      email = business_page.css(".email-business").try(:attr, "href").try(:value).try("split", ":").try(:last)
      if email.blank?
        temp_email = business_page.css(".sales-info").css("h1").text.split(" ").first.parameterize.to_s + "@videochatapro.com"
        temp_user = User.find_by_email(temp_email)
        if temp_user.present?
          user.email = temp_email.gsub("@", "_#{Time.now.to_i}@")
          user.password = temp_email.gsub("@", "_#{Time.now.to_i}@")
        else
          user.email = temp_email
          user.password = temp_email
        end
      else
        temp_user = User.find_by_email(email)
        if temp_user.present?
          user.email = email.gsub("@", "_#{Time.now.to_i}@")
          user.password = email.gsub("@", "_#{Time.now.to_i}@")
        else
          user.email = business_page.css(".email-business").try(:attr, "href").try(:value).try("split", ":").try(:last)
          user.password = business_page.css(".email-business").try(:attr, "href").try(:value).try("split", ":").try(:last)
        end
      end

      remote_picture_url = business_page.css(".banner-ad").try(:css, "img").try(:attr, "src").try(:value)
      user.remote_picture_url = if remote_picture_url.blank?
        business_page.css(".collage").try("css", "img").try(:first).try(:attr, "src")
      else
        remote_picture_url
      end

      user.video_url = business_page.css("video").try("attr", "src").try(:value)

      puts user.save!

    end
  rescue => e
    puts "Error INNER PAGE: =====>>>>> #{e.inspect}"
  end
end

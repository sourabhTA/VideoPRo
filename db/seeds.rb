# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
(SmsSetting.first || SmsSetting.new({
  api_key: "key",
  api_secret: "secret",
  phone_number: "1-555-555-5555"
})).save

admin = AdminUser.find_or_initialize_by(email: 'admin@example.com')
admin.password = 'password'
admin.password_confirmation = 'password'
admin.save!
admin.build_admin_permission
admin.admin_permission.update(super_admin: true)
puts "ADMIN CREATED ..."

avatar = Rails.root.join('test/fixtures/files/my-own-slug.png')

categories = ['Plumbers', 'Appliances', 'Mechanics', 'Electricians', 'Landscapers', 'HVACs']

Category.all.each do |category|
  Category::SEGMENTS.each do |segment|
    ['pro', 'business','customer'].each do |role|
      AutoEmail.create!(category_id: category.id, segment: segment, role: role, number_of_days: [1, 2, 3].sample,
                       subject: "This is sample subject",
                       pre_header: "This is sample pre header",
                       content: "This is main content",
                       button_text: "Button Text",
                       button_url: "/",
                       image: File.open(avatar),
                       automation: [0, 1].sample)
    end
  end
end


5.times do
  categories.each do |category_name|
    category = Category.find_or_initialize_by(name: category_name)
    category.save
    user = category.users.new(email: Faker::Internet.safe_email, name: Faker::Name.first_name, password: 'password',
                              password_confirmation: 'password', description: Faker::Lorem.paragraph,
                              agree_to_terms_and_service: true, phone_number: Faker::PhoneNumber.phone_number,
                              role: ['pro', 'business'].sample)

    user.picture = File.open(avatar)
    user.skip_confirmation!
    user.slug = SecureRandom.uuid
    user.save
  end
end

puts "CATEGORY AND FAKE Users CREATED ..."

pages = %w[home_page appliance electrician hvac plumber landscaper mechanic terms_and_conditions tools_to_succeed plumbing-do-it-yourself tradesman_signup business_signup]
pages.each do |slug|
  page = Page.find_or_initialize_by(slug: slug)

  page.title = 'Page Title' if page.title.blank?
  page.meta_keywords = 'keyword1, keyword2, keyword3, keyword4' if page.meta_keywords.blank?
  page.meta_description = 'Sample Meta description!' if page.meta_description.blank?
  page.header_logo = File.open(Rails.root.join('app/assets/images/logo.jpg')) if page.header_logo.blank?
  page.sub_header_text = 'Select Your Video Chat Pro <br/> Live Video Chat with Licensed Pros <br/> For All Your Do It Yourself Needs' if page.sub_header_text.blank?
  page.sub_header_background_image = File.open(Rails.root.join('app/assets/images/Electrician-plumber-appliance-landscaper-auto-mechanic-hvac-helping-hands.png')) if page.sub_header_background_image.blank?
  page.main_background_image = File.open(Rails.root.join('app/assets/images/water-background.jpg')) if page.main_background_image.blank?

  if slug == 'home_page'
    page.sub_header_logos_require =  true if page.sub_header_logos_require.blank?
  end

  page.sub_header_logo1 = File.open(Rails.root.join('app/assets/images/elementor-img1.jpg')) if page.sub_header_logo1.blank?
  page.sub_header_logo2 = File.open(Rails.root.join('app/assets/images/elementor-img2.jpg')) if page.sub_header_logo2.blank?
  page.sub_header_logo3 = File.open(Rails.root.join('app/assets/images/elementor-img3.jpg')) if page.sub_header_logo3.blank?
  page.sub_header_logo4 = File.open(Rails.root.join('app/assets/images/elementor-img4.jpg')) if page.sub_header_logo4.blank?
  page.sub_header_logo5 = File.open(Rails.root.join('app/assets/images/elementor-img5.jpg')) if page.sub_header_logo5.blank?
  page.sub_header_logo6 = File.open(Rails.root.join('app/assets/images/elementor-img6.jpg')) if page.sub_header_logo6.blank?

  if slug == 'home_page'
    page.main_steps_require =  true if page.main_steps_require.blank?
  end

  page.step1_image = File.open(Rails.root.join('app/assets/images/Step1-img.png')) if page.step1_image.blank?
  page.step2_image = File.open(Rails.root.join('app/assets/images/Step2-img.png')) if page.step2_image.blank?
  page.step3_image = File.open(Rails.root.join('app/assets/images/Step3-img.png')) if page.step3_image.blank?

  page.step1_caption = 'Select Trade' if page.step1_caption.blank?
  page.step2_caption = 'Schedule and Pay' if page.step2_caption.blank?
  page.step3_caption = 'Video Chat and Repair' if page.step3_caption.blank?

  page.main_details ||= <<~DETAILS
    Schedule A Live Video Chat Session With A Licensed Video Technician

    Please have the following items ready for your video chat:

    Flashlight, Tools Specified Per Trade, And a Towel
    Let a professional help you so your DIY repair doesn’t become a DIY disaster!

    Our team of Video Chat Pro’s will guide you through any DIY repair or replacement for a fraction of the cost of having a repair company come to your home. We will connect via Live Video Chat so you can show us the area that you are working on. Then the Licensed Video Chat Pro of your choosing will give you easy steps to complete the repair, a parts list can be emailed to you or an additional cost of $9.99. You will enjoy the confidence in knowing exactly what you need to purchase and the correct terminology when asking for materials at the hardware store of your choosing.

    We understand that sometimes you just want to work on your own home for many different reasons. When you are handy and just need a little direction, or you don’t want to give up and call a repair company this service is perfect for you. Become your families DIY Pro with the guidance of our Video Chat Pro’s. Gain confidence in your abilities through the guidance of a Licensed Video Chat Pro.
  DETAILS

  page.save_money  ||= <<~SAVE_MONEY
    Save Money

    Do It Yourself and save money. Empower yourself through the guidance of our Licensed Video Chat Pro’s to truly save money, less trips, less mistakes and less injuries.
  SAVE_MONEY

  page.save_time ||= <<~SAVE_TIME
    Save Time

    Schedule the best time for you. No waiting for a repair company to arrive or possibly never show up.
  SAVE_TIME

  page.new_skill ||= <<~NEW_SKILL
    Learn a New Skill

    Gain knowledge and confidence in your ability to complete your own repairs. Have a Licensed Video Pro guide you so your repair is performed correctly, with no disasters.
  NEW_SKILL

  page.no_stranger ||= <<~NO_STRANGER
    No Stranger in Your Home

    You never know who is coming to your home when you hire a stranger. Video Chat A Pro provides a safe secure way to educate yourself through guidance of a live Licensed Video Chat Pro.
  NO_STRANGER

  page.booking_step1_image = File.open(Rails.root.join('app/assets/images/booking-step1.png')) if page.booking_step1_image.blank?
  page.booking_step2_image = File.open(Rails.root.join('app/assets/images/booking-step2.png')) if page.booking_step2_image.blank?
  page.booking_step3_image = File.open(Rails.root.join('app/assets/images/booking-step3.png')) if page.booking_step3_image.blank?

  page.booking_step1_caption =  'Choose a Time' if page.booking_step1_caption.blank?
  page.booking_step2_caption =  'Start Video Chat' if page.booking_step2_caption.blank?
  page.booking_step3_caption =  'Fix Your Issue' if page.booking_step3_caption.blank?

  page.booking_step2_details ||= <<~DETAILS
    Access Your Video Chat Using a Cell Phone or Tablet

    It is quick and easy to connect to your video chat. A link will be emailed to you. No signing in or downloads needed.

    Our Technician will be waiting for you to join the Video Chat. Be ready with your appropriate materials (if you have them, if not ask the Technician to help with your list so you make as few trips as possible) and tools. If parts are recommended during your video chat our experts can email a parts list to you after the call for $9.99.
  DETAILS

  page.booking_step3_details ||= <<~DETAILS
    Repair Your Issue With A Pro’s Guidance

    Our Experts Will Provide Live Video Support and Can Email Supply Lists To You.

    Poof, it’s that easy. Much quicker and cheaper than having a contractor come to your home.
  DETAILS


  page.video_title ||= 'The Strangest Star In The Universe'
  page.video_url ||= 'https://www.youtube.com/watch?v=XyuXBYWZegY'
  page.save!
  puts "===================PAGE #{slug} CREATED========================"
end

footer_social_links = [['youtube', 'https://www.youtube.com/channel/UC4E7OT3QtmZ5Nv3DKbK1WIA'],
                       ['linkedin', 'https://www.linkedin.com/company/video-chat-a-pro-inc/'],
                       ['pinterest', 'https://www.pinterest.com/videochatapro/pins/']]

footer_social_links.each do |link|
  footer_social_link = FooterSocialLink.find_or_initialize_by(name: link.first)
  footer_social_link.url = link.last
  footer_social_link.save!
end

blog_categories = ['Category1', 'Category2', 'Category3']
blog_categories.each do |category_name|
  blog_category = BlogCategory.find_or_initialize_by(name: category_name)
  blog_category.save!
end



puts "===================SOCIAL LINKS CREATED========================"

blogs = [['Test Blog One', 'Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. '],
         ['Test Blog Two', 'Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. '],
         ['Test Blog Three', 'Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. Test Blog body, details are no provide yet, we will update it soon. ']]

blogs.each do |blog_data|
  blog = Blog.find_or_initialize_by(title: blog_data.first)
  blog.content = blog_data.last
  blog.blog_category_id = BlogCategory.all.map(&:id).sample
  blog.published_at = Time.zone.now
  blog.save!
end

puts "===================Blogs CREATED========================"

puts "PAGES DONE ..."

User.all.each do |user|
  user.update_attributes(city: Faker::Address.city, state: Faker::Address.state, zip: Faker::Address.zip)
end

AppSetting.create(direct_deposit_fee: 1.0, target_to_receive_funds: 100.0, pro_commission: 35.0, business_commission: 35.0)


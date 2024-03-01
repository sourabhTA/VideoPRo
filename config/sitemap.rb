# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = ENV.fetch("host_name")

SitemapGenerator::Sitemap.create do
  add root_path, changefreq: "daily", priority: 1.0

  add "/plumbing-repair-contractors", priority: 1.0
  add "/plumbing", priority: 1.0
  add "/electrical-repair-contractors", priority: 1.0
  add "/electrical", priority: 1.0
  add "/landscaping", priority: 1.0
  add "/auto-repair", priority: 1.0
  add "/hvac-repair-contractors", priority: 1.0
  add "/hvac", priority: 1.0
  add "/appliances", priority: 1.0
  add "/appliance-repair-company", priority: 1.0
  add "/home-improvements", priority: 1.0

  add search_diy_path, changefreq: "weekly", priority: 1.0
  add search_company_path, changefreq: "weekly", priority: 1.0

  diy_records = UserFilter.search(role: "pro").count
  company_records = UserFilter.search(role: "business").count

  ( (diy_records/10.0).ceil ).times do |x|
    add search_diy_path(page: x+1), changefreq: "weekly", priority: 1.0 if x+1 > 1
  end
  ( (company_records/10.0).ceil ).times do |x|
    add search_company_path(page: x+1), changefreq: "weekly", priority: 1.0 if x+1 > 1
  end

  Category.all.each do |category|
    add search_diy_path(trade: category.name.downcase), changefreq: "weekly", lastmod: category.updated_at, priority: 1.0
    add search_company_path(trade: category.name.downcase), changefreq: "weekly", lastmod: category.updated_at, priority: 1.0
    add slug_reviews_path(slug: category.name.downcase), changefreq: "daily", priority: 0.7

    diy_records = UserFilter.search(role: "pro", category_name: category.name.downcase).count
    company_records = UserFilter.search(role: "business", category_name: category.name.downcase).count

    ( (diy_records/10.0).ceil ).times do |x|
      add search_diy_path(trade: category.name.downcase, page: x+1), changefreq: "weekly", lastmod: category.updated_at, priority: 1.0 if x+1 > 1
    end
    ( (company_records/10.0).ceil ).times do |x|
      add search_company_path(trade: category.name.downcase, page: x+1), changefreq: "weekly", lastmod: category.updated_at, priority: 1.0 if x+1 > 1
    end
  end

  add new_tradesman_signup_path, changefreq: "monthly", priority: 0.9
  add new_business_signup_path, changefreq: "monthly", priority: 0.9

  # remove these url from sitemap because these urls are not available in website
  # add business_signup_path("business"), changefreq: "monthly", priority: 0.5
  # add pro_signup_path("pro"), changefreq: "monthly", priority: 0.5

  add "/faqs", changefreq: "weekly", priority: 0.8
  add "/contact_us", changefreq: "weekly", priority: 0.8
  add "/terms_and_conditions", changefreq: "weekly", priority: 0.8
  add "/careers", changefreq: "weekly", priority: 0.8

  add blogs_path, changefreq: "daily", priority: 0.7

  Blog.all.each do |blog|
    add blog_path(category_id: blog.blog_category.slug, id: blog.slug), changefreq: "weekly"
    add blogs_path(category_id: blog.blog_category.slug), changefreq: "weekly"
  end

  blog_records = Blog.count
  ( (blog_records/10.0).ceil ).times do |x|
    add blogs_path(page: x+1), changefreq: "weekly", priority: 1.0 if x+1 > 1
  end

  UserFilter.search(role: ["pro", "business"]).each do |user|
    status = user.custom_account_status.first
    unless user.deleted?
      add show_profile_path(user), changefreq: "daily"
      add user_reviews_path(slug: user.slug), changefreq: "daily"
      add new_booking_path(user), changefreq: "daily" if status != "pending"
      add new_scheduled_service_path(user), changefreq: "daily" if user.business?
    end
  end

  add slug_reviews_path, changefreq: "daily", priority: 0.7

  paths_to_check = [
    "/plumbing-repair-contractors",
    "/plumbing",
    "/electrical-repair-contractors",
    "/electrical",
    "/landscaper",
    "/landscaping",
    "/mechanics",
    "/auto-repair",
    "/hvac-repair-contractors",
    "/hvac",
    "/appliance-repair-company",
    "/appliances",
    "/home-improvements"
  ]

  paths_to_check.each do |path|
    page = Comfy::Cms::Page.find_by(full_path: path)
    if page
      page.children.map do |child|
        add child.full_path
      end
    end
  end
end

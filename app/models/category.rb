class Category < ApplicationRecord
  has_many :pros
  has_many :users
  has_many :auto_emails

  validates :name,
    presence: true,
    uniqueness: true

  SEGMENTS = [
    "All Segments",
    "Live",
    "Verified",
    "No Confirmation",
    "No Stripe",
    "No Plan",
    "Active Plan",
    "Scrapped"
  ]

  SLUG_CATEGORY_MAPPING = {
    "plumbing-do-it-yourself" => "Plumbers",
    "electrical-do-it-yourself" => "Electricians",
    "irrigation-do-it-yourself" => "Landscapers",
    "automotive-do-it-yourself" => "Mechanics",
    "hvac-do-it-yourself" => "HVACs",
    "do-it-yourself-home-improvement" => "Handyman",
    "appliance-do-it-yourself" => "Appliances",
    "plumbing-repair-contractors" => "Plumbers",
    "electrical-repair-contractors" => "Electricians",
    "landscaper" => "Landscapers",
    "mechanics" => "Mechanics",
    "hvac-repair-contractors" => "HVACs",
    "appliance-repair-company" => "Appliances"
  }

  CATEGORY_MAPPING_REVIEWS = {
    "Plumbers" => "Plumbing",
    "Electricians" => "Electrical",
    "Landscapers" => "Landscaping",
    "Mechanics" => "Automotive",
    "HVACs" => "HVAC",
    "Appliances" => "Appliance repair",
    "Handyman" => "Handyman"
  }

  def to_s
    name
  end

  def search_image
    file = name.parameterize.underscore + ".png"
    if File.exist?(Rails.root.join("app/assets/images", file))
      file
    else
      "category_placeholder.png"
    end
  end
end

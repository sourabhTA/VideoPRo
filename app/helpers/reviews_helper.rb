module ReviewsHelper
  def get_reviews
    if get_category
      reviews = User.includes(:reviews, license_informations: [:category]).base_search
        .where(role: ["pro","business"],profile_completed: true, stripe_account_status: "approved")
        .where.not(confirmed_at: nil).joins(:categories,:reviews)
        .where(categories: {name: @category.strip }, reviews: {rating: 5}).map{|user| user.reviews }.flatten.first(10)
    else
      reviews = Review.where(rating: 5).limit(10).includes(:user)
    end
    reviews
  end

  def get_category
    @category = nil
    if @fragment_list && @fragment_list["search_for"].present?
      @category = @fragment_list["search_for"]
    elsif Category::SLUG_CATEGORY_MAPPING[ @page.slug ].present?
      @category = Category::SLUG_CATEGORY_MAPPING[ @page.slug ]
    end
    @category
  end

  def review_title(user)
    return "Video Chat A Pro" if user.blank?
    if user.pro?
      "Check Reviews of #{user}"
    else
     "Check Reviews of #{user}"
    end
  end

  def h1_review_tag(user)
    return "<h1 class='text-center darkgrey'>Check Reviews of Video Chat A Pro</h1>" if user.blank?
    if user.pro?
      "<h1 class='text-center darkgrey'>Check #{ Category::CATEGORY_MAPPING_REVIEWS[user.categories.pluck(:name).first] } Review of #{user}</h1>"
    else
     "<h1 class='text-center darkgrey'>Check Reviews of #{user}</h1>"
    end
  end

  def h2_review_tag(user)
    return "Video Chat A Pro" if user.blank?
    if user.pro?
      "Check Secure Reviews of #{user}"
    else
      "Check Secure Reviews of #{user}"
    end
  end

  def review_meta_description(user)
    return "Video Chat A Pro" if user.blank?
    if user.pro?
      "Check Reviews of #{user}. Get guidance to do repairs yourself today. #{user} is highly skilled #{user.categories.pluck(:name).first} professional who uses video chat to assist you."
    else
      "#{user} gives video chat consultations to serve you better! Check these secure reviews to help guide your hiring decision. Save time and money today!"
    end
  end

  def star_rating_reviews(user)
    # rating = @user.reviews.blank? ? 1 : user.reviews.average(:rating).ceil
    request.base_url + asset_path("stars.jpg")
  end
end

module BookingsHelper
  def amount_per_session(user)
    @user.rate
  end

  def booking_h1_tag(user)
    if user.pro?
      "<h1>Book #{user} to learn How to Fix It Now</h1>"
    else
      "<h1>Book #{user} Now</h1>"
    end
  end

  def booking_h2_tag(user)
    if user.pro?
      "Schedule Now to Get Repair Instructions From #{user}"
    else
      "Schedule #{user} Now"
    end
  end

  def booking_title(user)
    if user.pro?
      "Book Now to Video Chat with #{user}"
    else
      "Save with #{user}"
    end
  end

  def booking_meta_description(user)
    if user.pro?
      "Book #{user} to get the most up to date instructions to fix your problem. There is no better place to learn exactly how to fix it properly."
    else
      "Save time on your #{ Category::CATEGORY_MAPPING_REVIEWS[user.categories.pluck(:name).first] } repair services today. Video chat with #{user} allows you to get price without the wait."
    end
  end
end

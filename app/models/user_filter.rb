class UserFilter
  def self.search(**options)
    new.search(**options)
  end

  def search(role: ["pro", "business"], category_name: nil, sort: nil, page: nil, near: nil, per_page: 10, featured: nil)
    query = User.includes(:reviews, license_informations: [:category])
      .base_search.where(role: role, profile_completed: true, stripe_account_status: "approved")
      .where.not(confirmed_at: nil)
      .or(User.includes(:reviews, license_informations: [:category]).base_search.where(role: role, is_imported: true))

    if category_name.present?
      query = query.joins(:categories).where(categories: {name: category_name.strip})
    end

    if !featured.nil?
      query = query.where(is_featured: featured)
    end

    if near.present?
      search = ( Rails.env.production? || Rails.env.staging? ) ? Geocoder.search(near, params: {countrycodes: "us"}).first : nil
      if search&.coordinates
        query = query.near(search.coordinates, 25, order: false).except(:select)
      end
    end

    if page.nil?
      User.public_send(sort_by(sort)).where(id: query.select(:id)).uniq.sort_by { |u| u.picture_url && u.available? ? 0 : 1 }
    else
      page = 1 if page.zero?
      User.public_send(sort_by(sort)).where(id: query.select(:id)).uniq.sort_by { |u| u.picture_url && u.available? ? 0 : 1 }.paginate(page: page, per_page: per_page)
    end
  end

  private

  def sort_by(sort)
    %w[
      featured_desc
      highest_rated
      highest_to_lowest_price
      lowest_to_highest_price
    ].detect(-> { "featured_desc" }) { |o| o == sort }
  end
end

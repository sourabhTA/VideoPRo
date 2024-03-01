class ReviewsController < ApplicationController
  helper_method :reviews, :page

  def index
    page
    reviews
    @exclusive_assets = ['application', 'stripe', 'map']
    if AppSetting.is_render_cms
      @cms_page = Comfy::Cms::Page.find_by(full_path: request.path) || Comfy::Cms::Page.find_by(slug: request.path.split("/")[1])
      if @cms_page
        render cms_page: @cms_page.full_path
      end
    end
  end

  private

  def page
    @page ||= Page.find_by(slug: "reviews")
  end

  def reviews
    if params[:slug].present?
      @reviews ||= User.includes(:reviews, license_informations: [:category]).where(role: ["pro","business"])
        .joins(:categories).where(categories: {name: params[:slug] }).map{|user| user.reviews }.flatten
    else
      @reviews ||= Review.order(id: :desc)
    end
  end
end

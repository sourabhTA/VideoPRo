class BlogsController < ApplicationController
  before_action :no_canonical, only: [:index]
  layout "extra"

  def index
    @hideMenu = true
    @exclusive_assets = ['application', 'stripe', 'map']
    if params[:category_id].blank?
      @blogs = Blog.includes(:blog_category).paginate(page: params[:page], per_page: 10).order(published_at: :desc)
    else
      blog_category = BlogCategory.find_by_slug(params[:category_id])
      if blog_category.nil?
        redirect_to(blogs_path, alert: "Please try other blog's category.") && return
      else
        @blogs = blog_category.blogs.paginate(page: params[:page], per_page: 10).order(published_at: :desc)
      end
    end

    if @blogs.current_page > @blogs.total_pages
      redirect_to(blogs_path(category_id: params[:category_id], page: @blogs.total_pages)) && return
    end
  end

  def show
    @blog = Blog.find_by_slug(params[:id])
    @exclusive_assets = ['application', 'stripe', 'map']
    @hideMenu = true
    category_slug = @blog&.blog_category&.slug
    if @blog.blank?
      @original_blog_path = "/blog/#{category_slug}"
    else
      @original_blog_path = "/blog/#{category_slug}/#{@blog.slug}"
    end
    no_canonical if category_slug != params[:category_id]

    redirect_to(blogs_path, alert: "This blog do not exist.") && return if @blog.blank?
  end
end

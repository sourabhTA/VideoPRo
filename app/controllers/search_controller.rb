class SearchController < ApplicationController
  before_action :no_canonical, only: [:index]
  before_action :load_cms_page  if !AppSetting.is_render_cms

  def index
    near = params[:near]
    @hideMenu = true
    @no_index = true
    @exclusive_assets = ['application', 'stripe', 'map']

    @users = if company_path? && near.present?
      UserFilter.search(
        role: role,
        category_name: search_params[:trade],
        sort: search_params[:sort_by],
        page: page,
        near: near
      )
    elsif company_path?
      UserFilter.search(
        role: role,
        category_name: search_params[:trade],
        sort: search_params[:sort_by],
        page: page
      )
    else
      UserFilter.search(
        role: role,
        category_name: search_params[:trade],
        sort: search_params[:sort_by],
        page: page,
        featured: false
      )
    end
    @featured_users = if company_path?
    else
      UserFilter.search(
        role: role,
        category_name: search_params[:trade],
        featured: true
      )
    end
    if @users.current_page > @users.total_pages
      if company_path?
        redirect_to(search_company_path(trade: params[:trade], page: @users.total_pages)) && return
      elsif diy_path?
        redirect_to(search_diy_path(trade: params[:trade], page: @users.total_pages)) && return
      end
    end
    
    if !request.xhr? && AppSetting.is_render_cms
      load_page_via_cms
    end
  end

  private

  def page
    search_params.fetch(:page, 1).to_i
  end

  def search_params
    params.permit(:trade, :sort_by, :page, :near)
  end

  def role
    if diy_path?
      "pro"
    elsif company_path?
      "business"
    end
  end

  def load_cms_page
    page_data = request.path.split("/").detect(&:present?)
    load_page_data(page_data)
  end
end

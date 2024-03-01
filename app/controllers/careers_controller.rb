class CareersController < ApplicationController
  layout "extra"

  def index
    @careers = Career.career_list
    @hideMenu = true
    if AppSetting.is_render_cms
      load_page_via_cms
    else
      @page = Page.find_by(slug: "careers")
    end
  end
end

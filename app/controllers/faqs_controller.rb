class FaqsController < ApplicationController
    before_action :load_page_via_cms, only: [:index]

  def index
    load_page_data("faqs")
    @hideMenu = true
    render "main"
  end
end

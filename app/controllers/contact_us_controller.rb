class ContactUsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]
  layout "extra"

  def new
    @contact = Contact.new(name: current_user.name, email: current_user.email)
    render layout: "authenticated"
  end

  def create
    @contact = Contact.new(
      name: current_user.name,
      email: current_user.email,
      body: contact_params[:body]
    )
    if @contact.save
      redirect_to edit_profile_path(current_user), notice: "Thanks for your message, we will get back to you soon!"
    else
      render :new, layout: "authenticated", status: 422
    end
  end

  def do_contact
    @hideMenu = true
    @cms_page = Comfy::Cms::Page.find_by(full_path: request.path) || Comfy::Cms::Page.find_by(slug: request.path.split("/")[1])
    if request.post?
      if verify_recaptcha
        @contact = Contact.new(contact_params)
        if @contact.save
          redirect_to root_path, notice: "Thanks for your message, we will get back to you soon!"
        else
          flash[:alert] = "Message was not successfully posted!"
          render cms_page: @cms_page.full_path if @cms_page
        end
      else
        @contact = Contact.new
        render cms_page: @cms_page.full_path if @cms_page
      end
    else
      @contact = Contact.new
      if AppSetting.is_render_cms
        @cms_page = Comfy::Cms::Page.find_by(full_path: request.path) || Comfy::Cms::Page.find_by(slug: request.path.split("/")[1])
        render cms_page: @cms_page.full_path if @cms_page
      end
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :body)
  end
end

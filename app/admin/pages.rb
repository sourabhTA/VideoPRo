ActiveAdmin.register Page do
  menu false
  permit_params :id, :slug, :title, :meta_keywords, :meta_description, :header_logo, :sub_header_text, :sub_header_background_image,
    :sub_header_logos_require, :sub_header_logo1, :sub_header_logo2, :sub_header_logo3, :sub_header_logo4,
    :sub_header_logo5, :sub_header_logo6, :main_steps_require, :step1_image, :step2_image, :step3_image,
    :main_details, :save_money, :save_time, :new_skill, :no_stranger, :booking_step1_image, :booking_step1_caption,
    :booking_step2_image, :booking_step2_caption, :booking_step3_image, :booking_step3_caption, :booking_step2_details,
    :booking_step3_details, :video_title, :video_url, :step1_caption, :step2_caption, :step3_caption, :main_background_image,
    :shop_button_text, :shop_button_link, :search_heading1, :search_heading2, :why_heading, :what_heading, :video_review_heading,
    :remove_sub_header_background_image,
    :remove_main_background_image

  config.filters = true
  config.per_page = 80
  config.sort_order = "slug_asc"

  filter :slug
  filter :title

  index do
    selectable_column
    column :slug do |page|
      "/#{page.slug}"
    end
    column :title
    column "URL" do |page|
      link_to "Open", page_path(page.slug), target: :_blank
    end
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "SEO Details" do
      f.input :slug
      f.input :title
      f.input :shop_button_text
      f.input :shop_button_link
      f.input :meta_keywords
      f.input :meta_description
      f.input :sub_header_logos_require
      f.input :main_steps_require
    end
    f.inputs "Text And details" do
      if f.object.slug != "terms_and_conditions" && f.object.slug != "tools_to_succeed"
        f.input :sub_header_text, input_html: {class: "tinymce"}
      end

      f.input :main_details, input_html: {class: "tinymce"}

      if f.object.slug != "terms_and_conditions" && f.object.slug != "tools_to_succeed"
      end

      f.input :search_heading1, input_html: {class: "tinymce"}
      f.input :search_heading2, input_html: {class: "tinymce"}
      f.input :why_heading, input_html: {class: "tinymce"}
      f.input :what_heading, input_html: {class: "tinymce"}
      f.input :video_review_heading, input_html: {class: "tinymce"}

      # if f.object.slug != 'terms_and_conditions' && f.object.slug != 'tools_to_succeed'
      #   f.input :step1_caption, :wrapper_html => { :class => 'two_fl' }
      #   f.input :step2_caption, :wrapper_html => { :class => 'two_fl' }
      #   f.input :step3_caption, :wrapper_html => { :class => 'two_fl' }
      #   f.input :booking_step1_caption, :wrapper_html => { :class => 'two_fl' }
      #   f.input :booking_step2_caption, :wrapper_html => { :class => 'two_fl' }
      #   f.input :booking_step3_caption, :wrapper_html => { :class => 'two_fl' }
      #   f.input :sub_header_text, as: :tinymce
      # end
      #
      # f.input :main_details, as: :tinymce

      if f.object.slug == "home_page"
        f.input :save_money, input_html: {class: "tinymce"}
        f.input :save_time, input_html: {class: "tinymce"}
        f.input :new_skill, input_html: {class: "tinymce"}
        f.input :no_stranger, input_html: {class: "tinymce"}
        f.input :booking_step2_details, label: "Trade description", input_html: {class: "tinymce"}
        # f.input :booking_step3_details, :input_html => { :class => "tinymce" }
      end
    end

    f.inputs "Images and logos" do
      div class: "row" do
        div class: "col-md-4 text-center" do
          div class: "image-container" do
            img src: f.object.header_logo, class: "admin-page-image" if f.object.header_logo.present?
          end
          f.input :header_logo, wrapper_html: {class: "fl"}
        end
        div class: "col-md-4 text-center" do
          if f.object.slug != "terms_and_conditions" && f.object.slug != "tools_to_succeed"
            div class: "image-container" do
              img src: f.object.sub_header_background_image, class: "admin-page-image" if f.object.sub_header_background_image.present?
            end
            f.input :sub_header_background_image, wrapper_html: {class: "fl"}
            div {
              <<~HTML.html_safe
                <label>
                  <input type="checkbox" class="hide remove-image" name="page[remove_sub_header_background_image]" />
                  <div class="btn btn-danger">
                    Remove Sub Header Image
                  </div>
                </label>
              HTML
            }
          end
        end
        div class: "col-md-4 text-center" do
          if f.object.slug != "terms_and_conditions" && f.object.slug != "tools_to_succeed"
            div class: "image-container" do
              img src: f.object.main_background_image, class: "admin-page-image" if f.object.main_background_image.present?
            end
            f.input :main_background_image, wrapper_html: {class: "fl"}
            div {
              <<~HTML.html_safe
                <label>
                  <input type="checkbox" class="hide remove-image" name="page[remove_main_background_image]" />
                  <div class="btn btn-danger">
                    Remove Main Background Image
                  </div>
                </label>
              HTML
            }
          end
        end
      end
    end
    if f.object.slug != "terms_and_conditions"
      f.inputs "Video Data" do
        f.input :video_title
        f.input :video_url
      end
    end

    f.actions
  end
end

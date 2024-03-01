ActiveAdmin.register Category do
  permit_params :name, :description, :display_name, :rating, :review
  config.batch_actions = false

  controller do
    helper_method def search_promo_video
      @search_promo_video ||= Video.search_promo
    end

    helper_method def search_promo_video_business
      @search_promo_video_business ||= Video.search_promo_business
    end

    def video
      finder = {
        Video::SEARCH_PROMO => :search_promo,
        Video::SEARCH_PROMO_BUSINESS => :search_promo_business
      }.fetch(params[:promo][:id])
      @video ||= Video.public_send(finder)
    end
  end

  collection_action :upload_search_promo, method: :post do
    if params.dig(:promo, :video).present?
      video.video = params[:promo][:video]
    end
    if params.dig(:promo, :poster).present?
      video.poster = params[:promo][:poster]
    end
    video.save!

    redirect_to collection_path, notice: "Search Promo Uploaded!"
  end

  collection_action :delete_search_promo, method: :delete do
    video.remove_video!
    video.remove_poster!
    video.save

    redirect_to collection_path, notice: "Deleted Promo Video!"
  end

  index do
    column :name
    column :description
    column :display_name
    column :rating
    column :review
    actions

    panel "Promo Video", only: :index do
      tabs do
        tab :diy do
          render partial: "promo_form", locals: {form_video: search_promo_video}
        end

        tab :business do
          render partial: "promo_form", locals: {form_video: search_promo_video_business}
        end
      end
    end
  end

  filter :name
  filter :auth_emails
  filter :created_at
  filter :updated_at
  filter :display_name
  filter :description
  filter :rating
  filter :review
end

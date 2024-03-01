ActiveAdmin.register HomePageTrade do
  Formtastic::FormBuilder.perform_browser_validations = true
  permit_params :link, :title, :body, :video, :poster

  config.filters = false
  config.batch_actions = false

  index do
    column do |trade|
      div for: trade do
        div trade.title
        video class: "admin-video", controls: true, poster: trade.poster&.url do
          source src: trade.video
        end
      end
    end

    column do |trade|
      trade.link
    end

    column do |trade|
      simple_format trade.body
    end
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :title, as: :string
    end
    f.inputs do
      f.input :body
    end
    f.inputs do
      f.input :link, as: :string
    end
    f.inputs do
      f.input :poster, label: "Poster Image", input_html: {required: true}
    end
    f.inputs do
      f.input :video, label: "Video", input_html: {required: true}
    end
    f.actions
  end
end

ActiveAdmin.register Blog do
  permit_params :title, :content, :blog_category_id, :published_at, :video_url,
    :image, :slug, :meta_keywords, :meta_description

  includes :blog_category

  controller do
    defaults finder: :find_by_slug
  end

  form do |f|
    f.inputs do
      f.input :blog_category_id, as: :select, collection: BlogCategory.all.map { |p| [p.name, p.id] }, prompt: "Select Category"
      f.input :slug
      f.input :title
      f.input :meta_keywords
      f.input :meta_description
      f.input :content, input_html: {class: "tinymce"}
      f.input :published_at
      f.input :video_url
      f.input :image
    end
    f.actions
  end

  index do
    selectable_column
    column :title
    column :content do |c|
      c.content[0, 100].strip + "..."
    end
    column :blog_category
    column :image do |c|
      content_tag(:img, nil, src: c.image, style: "width: 30px;height: 30px;")
    end
    column :video_url do |c|
      c.video_url[0, 50].strip + "..." if c.video_url
    end
    column :meta_description do |data|
      truncate(data.meta_description, omision: "...", length: 70)
    end
    column :meta_keywords do |data|
      truncate(data.meta_keywords, omision: "...", length: 70)
    end
    column :published_at do |blog|
      blog.published_at&.strftime("%I:%M %p")
    end
    actions
  end
end

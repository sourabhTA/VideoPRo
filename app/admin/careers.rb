ActiveAdmin.register Career do
  permit_params :title, :content, :button1_text, :button1_link, :button2_text, :button2_link, :image

  filter :title
  filter :content

  index do
    selectable_column

    column :image do |c|
      content_tag(:img, nil, src: c.image, style: "width: 30px;height: 30px;")
    end
    column :title
    column :content do |c|
      c.content[0, 100].strip + "..."
    end
    column :button_1 do |c|
      link_to c.button1_text, c.button1_link
    end
    column :button_2 do |c|
      link_to c.button2_text, c.button2_link
    end
    actions
  end
end

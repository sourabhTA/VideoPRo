ActiveAdmin.register Faq do
  permit_params :question, :answer

  index do
    selectable_column

    column :question
    column :answer do |c|
      c.answer[0, 100].strip + "..."
    end
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs "Faqs" do
      f.input :question, input_html: {class: "tinymce"}
      f.input :answer, input_html: {class: "tinymce"}
    end
    f.actions
  end
end

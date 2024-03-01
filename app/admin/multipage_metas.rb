ActiveAdmin.register MultipageMeta do
  permit_params :title, :description, :page_type, :h1_tag, :h2_tag

  index do
    selectable_column
    id_column
    column :title
    column :description do |data|
      truncate(data.description, omision: "...", length: 70)
    end
    column :h1_tag do |data|
      truncate(data.h1_tag, omision: "...", length: 70)
    end
    column :h2_tag do |data|
      truncate(data.h2_tag, omision: "...", length: 70)
    end
    column :page_type
    column :created_at
    actions
  end

	form do |f|
	  f.inputs do
	    f.input :title
	    f.input :description
	    f.input :h1_tag
      f.input :h2_tag
	    f.input :page_type, :label => 'Page Type', :as => :select, :collection => MultipageMeta.meta_page_type.map{ |u| u }
	  end
    actions
	end

end

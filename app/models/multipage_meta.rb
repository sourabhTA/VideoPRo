class MultipageMeta < ApplicationRecord
	def self.meta_page_type
		(
			{"diy"=>"diy","company"=>"company", "blogs"=>"blogs"}
			.merge!(
				Hash[*Category.all.map{|bc| ["diy_"+bc.name.downcase, "company_"+bc.name.downcase]  }.flatten
				.map{ |x| [x,x] }
				.flatten].merge!(
					Hash[*BlogCategory.all.map{|bc| "blog_"+bc.name.downcase.gsub(' ','_') }.map{|x| [x,x]}.flatten]
				)
			)
		)
	end

	def self.get_meta(key, page_no)
		related_metas = where(page_type: key)
		meta_count = related_metas.count
		related_metas[(page_no%meta_count) - 1] if meta_count != 0
	end
end

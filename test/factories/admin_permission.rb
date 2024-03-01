FactoryBot.define do
  factory :admin_permission do
    admin_user
    super_admin { false }

    cms_create { false }
    cms_edit { false }
    cms_delete { false }

    blog_create { false }
    blog_edit { false }
    blog_delete { false }
  end
end

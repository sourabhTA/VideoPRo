ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation, admin_permission_attributes: [
    :super_admin,
    :cms_create,
    :cms_edit,
    :cms_delete,
    :blog_create,
    :blog_edit,
    :blog_delete
  ]

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form html: {novalidate: false} do |f|
    inputs do
      input :email

      if f.object.persisted?
        div class: "password-fields hide" do
          input :password, input_html: {required: true, disabled: true}
          input :password_confirmation, input_html: {required: true, disabled: true}
        end

        a id: "change-password", class: "btn btn-default" do
          "Change Password"
        end
      else
        input :password, input_html: {required: true}
        input :password_confirmation, input_html: {required: true}
      end

      if f.object.admin_permission.blank?
        f.object.build_admin_permission
      end

      f.semantic_fields_for :admin_permission do |perm|
        table id: "acl-table", class: "striped" do
          tr do
            perm.inputs do
              perm.input :super_admin, input_html: {style: "margin-top: 30px;"}, as: :boolean
            end
          end

          tr do
            th ""
            th "create"
            th "edit"
            th "delete"
          end

          tr do
            td "CMS"
            td do
              perm.inputs do
                perm.input :cms_create, label: ""
              end
            end
            td do
              perm.inputs do
                perm.input :cms_edit, label: ""
              end
            end
            td do
              perm.inputs do
                perm.input :cms_delete, label: ""
              end
            end
          end

          tr do
            td "Blog"
            td do
              perm.inputs do
                perm.input :blog_create, label: ""
              end
            end
            td do
              perm.inputs do
                perm.input :blog_edit, label: ""
              end
            end
            td do
              perm.inputs do
                perm.input :blog_delete, label: ""
              end
            end
          end
        end
      end

      actions
    end
  end
end

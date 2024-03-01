ActiveAdmin.register Claim do
  actions :all, except: [:new, :edit, :destroy]

  includes :user

  permit_params :user_id, :first_name, :last_name, :email, :phone_number, :is_approved

  config.filters = false

  index do
    column :user
    column :first_name
    column :last_name
    column :email
    column :phone_number
    column :is_approved

    column "Mark Approve" do |resource|
      if resource.is_approved?
        "Approved"
      else
        link_to "Mark Approve", approve_admin_claim_path(resource), class: "member_link"
      end
    end

    column "Unlock profile" do |resource|
      if resource.is_approved? && resource.user.present?
        if resource.user.locked_by_admin?
          link_to "Unlock profile", unlock_admin_claim_path(resource), class: "member_link"
        else
          "Unlocked"
        end
      else
        "Waiting For Approval"
      end
    end
  end

  member_action :approve, method: [:get] do
    @claim = Claim.find_by id: params[:id]
    @claim.update_attribute :is_approved, true
    GenericMailer.send_approval_email(@claim).deliver
    flash[:notice] = "Claim approved successfully!"
    redirect_to admin_claims_path
  end

  member_action :unlock, method: [:get] do
    @claim = Claim.find_by id: params[:id]
    @claim.user.update_attribute :locked_by_admin, false
    GenericMailer.send_profile_unlocked_email(@claim).deliver
    flash[:notice] = "Profile unlocked successfully!"
    redirect_to admin_claims_path
  end
end

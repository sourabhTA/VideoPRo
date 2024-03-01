class ClaimsController < ApplicationController
  before_action :no_index

  def create
    @claim = Claim.new(claim_params)
    @user = @claim.user

    if verify_recaptcha
      if @claim.save
        flash[:notice] = "Thanks for claiming, Admin will contact you shortly"
        redirect_to root_path
      else
        render "/profiles/claim_business"
      end
    else
      render "/profiles/claim_business"
    end
  end

  def claim_params
    accessible = [ :user_id, :first_name, :last_name, :email, :phone_number]
    params.require(:claim).permit(accessible)
  end
end

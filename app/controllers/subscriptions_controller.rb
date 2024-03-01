class SubscriptionsController < AuthenticatedController
  # before_action except: [:index] do
  #   check_permissions_for(:business)
  # end
  before_action :load_plan, except: [:index, :edit, :update]
  before_action :validate_plan, only: [:new, :create]

  def index
    @plans = current_user.pro? ? Plan.active.free_pro.includes(:features) : Plan.active.not_free_pro.in_order.includes(:features)
  end

  def new
    @subscriber = current_user
    @error = nil
    if !current_user.confirmed? && !current_user.profile_completed?
      @error = "Please complete your profile first, thanks."
      respond_to do |format|
        format.html { redirect_to(edit_profile_path(current_user), alert: @error) && return }
        format.js   { }
      end
    end
  end

  def edit
    @subscriber = current_user
  end

  def create
    @subscriber = current_user
    stripe_token = params[:stripeToken]

    # @subscriber.update(user_params)
    if @subscriber.save_and_make_payment(@plan, stripe_token)
      # if @subscriber.is_claimed? && @subscriber.claim_approved?
      #   redirect_to("https://claim.videochatapro.com/get-offer/thank-you/") && return rescue ""
      # end
      respond_to do |format|
        format.js {
          render layout: false,
          message: "Plan subscribed successfully!",
          content_type: 'text/javascript'
        }
        format.html { redirect_to subscriptions_path, notice: "Plan subscribed successfully!" }
      end
    else
      @error = "Plan was not saved successfully!"
      respond_to do |format|
        format.js   { render layout: false, message: @error, content_type: 'text/javascript' }
        format.html { render :new, danger: @error }
      end
    end
  rescue => e
    @error = e.message
    flash[:error] = @error
    respond_to do |format|
      format.js   { render layout: false, message: @error, content_type: 'text/javascript' }
      format.html { render :new, danger: @error }
    end
  end

  def update
    @subscriber = User.find_by_slug(params[:slug])
    stripe_token = params[:stripeToken]
    if @subscriber.update_customer_card_token(stripe_token)
      redirect_to subscriptions_path, notice: "Card Changed successfully!"
    else
      render :edit, danger: "Card was not updated successfully!"
    end
  end

  protected

  def load_plan
    @plan = Plan.find params[:plan_id]
  end

  def validate_plan
    redirect_to(subscriptions_path, alert: "Please select the correct plan.") && return if @plan.nil?
  end

  def user_params
    accessible = [:is_van_paid]
    params.require(:user).permit(accessible)
  end
end

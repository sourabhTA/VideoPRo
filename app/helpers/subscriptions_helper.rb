module SubscriptionsHelper
  def subscription_class(plan)
    return "selected_subscription_box" if current_user && current_user.plan_id == plan.id
  end

  def selected?(plan)
    current_user.plan_id == plan.id
  end
end

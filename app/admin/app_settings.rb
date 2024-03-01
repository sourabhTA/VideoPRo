ActiveAdmin.register AppSetting do
  permit_params :is_render_cms, :direct_deposit_fee, :target_to_receive_funds, :pro_commission, :business_commission
  actions :all, except: [:new, :create, :destroy]
  config.filters = false
end

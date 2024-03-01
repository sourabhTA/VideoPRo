ActiveAdmin.register Endorsement do
  permit_params :image, :alt, :link
  config.filters = false
end

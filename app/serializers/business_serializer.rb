class BusinessSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :slug, :role, :rate, :address
end

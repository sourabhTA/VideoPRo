class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :slug, :role, :rate
end

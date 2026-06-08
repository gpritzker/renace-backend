class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :dni, :birth_date, :phone, :admin, :premium, :created_at
end
class CapsuleSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :open_at, :approved, :created_at, :updated_at
  belongs_to :user
  has_many :memories
end
class MemorySerializer < ActiveModel::Serializer
  attributes :id, :capsule_id, :content, :media_url, :memory_type, :created_at, :updated_at

  belongs_to :capsule
end
class MemorySerializer < ApplicationSerializer
  attributes :id,
             :capsule_id,
             :content,
             :memory_type,
             :created_at,
             :updated_at,
             :file_url

  belongs_to :capsule

  def file_url
    return nil unless object.file.attached?
  
    object.file.service_url(
      expires_in: 10.minutes,
      disposition: 'inline'
    )
  end  
end
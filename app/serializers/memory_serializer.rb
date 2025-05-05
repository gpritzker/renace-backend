class MemorySerializer < ActiveModel::Serializer
  attributes :id,
             :capsule_id,
             :content,
             :memory_type,
             :created_at,
             :updated_at,
             :rails_url,
             :s3_url

  belongs_to :capsule

  def rails_url
    return nil unless object.file.attached?

    Rails.application.routes.url_helpers.rails_blob_url(
      object.file,
      host: default_host, # definilo si no tenés ApplicationSerializer
      disposition: 'inline'
    )
  end

  def s3_url
    return nil unless object.file.attached?
  
    object.file.blob.service.send(:url_for_direct_upload, object.file.key, expires_in: 10.minutes, content_type: object.file.blob.content_type)
  end

  private

  def default_host
    ENV['APP_HOST'] || 'http://localhost:3000'
  end
end
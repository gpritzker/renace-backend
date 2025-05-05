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

    Rails.application.routes.url_helpers.rails_blob_url(object.file, host: default_host)
  end
end
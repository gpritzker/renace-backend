class Memory < ApplicationRecord
  belongs_to :capsule

  has_one_attached :file

  enum memory_type: { text: 'text', image: 'image', video: 'video', audio: 'audio' }

  validates :content, presence: true, if: -> { text? }
  validates :memory_type, presence: true, inclusion: { in: memory_types.keys }

  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif].freeze
  ALLOWED_VIDEO_TYPES = %w[video/mp4 video/quicktime video/webm].freeze
  ALLOWED_AUDIO_TYPES = %w[audio/mpeg audio/mp4 audio/wav audio/ogg audio/webm].freeze

  MAX_IMAGE_SIZE = 20.megabytes
  MAX_VIDEO_SIZE = 500.megabytes
  MAX_AUDIO_SIZE = 100.megabytes

  validate :validate_file_attachment, if: -> { file.attached? }

  private

  def validate_file_attachment
    blob = file.blob

    case memory_type.to_s
    when 'image'
      unless ALLOWED_IMAGE_TYPES.include?(blob.content_type)
        errors.add(:file, "debe ser una imagen JPEG, PNG, WebP o GIF")
      end
      if blob.byte_size > MAX_IMAGE_SIZE
        errors.add(:file, "no puede superar #{MAX_IMAGE_SIZE / 1.megabyte}MB")
      end
    when 'video'
      unless ALLOWED_VIDEO_TYPES.include?(blob.content_type)
        errors.add(:file, "debe ser un video MP4, MOV o WebM")
      end
      if blob.byte_size > MAX_VIDEO_SIZE
        errors.add(:file, "no puede superar #{MAX_VIDEO_SIZE / 1.megabyte}MB")
      end
    when 'audio'
      unless ALLOWED_AUDIO_TYPES.include?(blob.content_type)
        errors.add(:file, "debe ser un audio MP3, MP4, WAV, OGG o WebM")
      end
      if blob.byte_size > MAX_AUDIO_SIZE
        errors.add(:file, "no puede superar #{MAX_AUDIO_SIZE / 1.megabyte}MB")
      end
    end
  end
end

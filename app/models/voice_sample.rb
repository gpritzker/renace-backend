class VoiceSample < ApplicationRecord
  belongs_to :user
  has_one_attached :audio

  validates :audio, presence: true
  validate :audio_duration, if: -> { audio.attached? }

  private

  def audio_duration
    size_kb = audio.blob.byte_size / 1024.0
    # audio/webm a ~32kbps: 4.6s ≈ ~18KB, usamos 15KB como mínimo conservador
    errors.add(:audio, 'debe tener al menos 5 segundos de duración') if size_kb < 15
  end
end

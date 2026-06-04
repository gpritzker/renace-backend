class VoiceSample < ApplicationRecord
  belongs_to :user
  has_one_attached :audio

  validates :audio, presence: true
end

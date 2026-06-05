class CachedAudio < ApplicationRecord
  has_one_attached :audio_file

  def self.fetch(voice_id:, text:, &block)
    key = Digest::SHA256.hexdigest("#{voice_id}:#{text}:multilingual_v2")

    record = find_by(lookup_key: key)
    if record&.audio_file&.attached? && record.expires_at > Time.current
      return record.audio_file.download
    end

    audio_bytes = block.call

    record ||= new(lookup_key: key)
    record.expires_at = 30.days.from_now
    record.audio_file.attach(
      io: StringIO.new(audio_bytes),
      filename: "#{key}.mp3",
      content_type: 'audio/mpeg'
    )
    record.save!

    audio_bytes
  rescue => e
    Rails.logger.warn "AudioCache miss (#{e.message}) — skipping cache"
    raise
  end
end

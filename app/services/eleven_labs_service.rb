require 'net/http'
require 'json'

class ElevenLabsService
  BASE_URL = 'https://api.elevenlabs.io/v1'

  def initialize
    @api_key = ENV.fetch('ELEVENLABS_API_KEY')
  end

  # Sube muestras de audio y crea un voice clone.
  # audio_blobs: array de ActiveStorage::Blob
  # Retorna el voice_id generado por ElevenLabs.
  def clone_voice(name:, audio_blobs:)
    uri = URI("#{BASE_URL}/voices/add")
    req = Net::HTTP::Post.new(uri)
    req['xi-api-key'] = @api_key

    boundary = "RenaceBoundary#{SecureRandom.hex(8)}"
    req.content_type = "multipart/form-data; boundary=#{boundary}"

    body = []
    body << "--#{boundary}\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\n#{name}\r\n"
    body << "--#{boundary}\r\nContent-Disposition: form-data; name=\"description\"\r\n\r\nVoz clonada de usuario Renace\r\n"
    body << "--#{boundary}\r\nContent-Disposition: form-data; name=\"remove_background_noise\"\r\n\r\ntrue\r\n"

    audio_blobs = audio_blobs.uniq(&:checksum)

    audio_blobs.each_with_index do |blob, i|
      filename = blob.filename.to_s
      content_type = blob.content_type || 'audio/webm'
      data = blob.download
      body << "--#{boundary}\r\nContent-Disposition: form-data; name=\"files\"; filename=\"#{filename}\"\r\nContent-Type: #{content_type}\r\n\r\n#{data}\r\n"
    end

    body << "--#{boundary}--\r\n"
    req.body = body.join

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
    raise "ElevenLabs clone error: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)['voice_id']
  end

  # Genera audio en la voz clonada. Retorna bytes de MP3 (cacheado 30 días).
  def generate_speech(voice_id:, text:)
    CachedAudio.fetch(voice_id: voice_id, text: text) do
      call_elevenlabs_tts(voice_id: voice_id, text: text)
    end
  end

  def delete_voice(voice_id)
    uri = URI("#{BASE_URL}/voices/#{voice_id}")
    req = Net::HTTP::Delete.new(uri)
    req['xi-api-key'] = @api_key
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |h| h.request(req) }
  end

  private

  def call_elevenlabs_tts(voice_id:, text:)
    uri = URI("#{BASE_URL}/text-to-speech/#{voice_id}?output_format=mp3_44100_128")
    req = Net::HTTP::Post.new(uri)
    req['xi-api-key'] = @api_key
    req['Content-Type'] = 'application/json'
    req['Accept'] = 'audio/mpeg'
    req.body = {
      text: text,
      model_id: 'eleven_multilingual_v2',
      voice_settings: {
        stability: 0.5,
        similarity_boost: 0.85,
        style: 0.1,
        use_speaker_boost: true
      }
    }.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 30) { |h| h.request(req) }
    raise "ElevenLabs TTS error: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  end
end

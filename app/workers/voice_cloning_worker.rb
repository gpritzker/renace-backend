class VoiceCloningWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(user_id)
    user = User.find(user_id)
    blobs = user.voice_samples.map { |s| s.audio.blob }

    voice_id = ElevenLabsService.new.clone_voice(
      name: "renace_user_#{user_id}",
      audio_blobs: blobs
    )

    user.update!(elevenlabs_voice_id: voice_id, voice_clone_status: 'ready')
  rescue => e
    User.find_by(id: user_id)&.update(voice_clone_status: 'error')
    raise e
  end
end

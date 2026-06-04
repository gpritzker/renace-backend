module Api
  module V1
    class PublicCapsulesController < ActionController::API

      def show
        capsule = Capsule.approved.find_by(id: params[:id])
        return render json: { error: 'Cápsula no encontrada' }, status: :not_found unless capsule

        render json: {
          id: capsule.id,
          title: capsule.title,
          description: capsule.description,
          open_at: capsule.open_at,
          has_voice: capsule.user.elevenlabs_voice_id.present?,
          owner_name: capsule.user.email.split('@').first,
          memories: capsule.memories.where(memory_type: 'text').order(:created_at).map do |m|
            { id: m.id, content: m.content }
          end
        }
      end

      # Narra un texto puntual con la voz del dueño (para cada memoria individual)
      def narrate
        capsule = Capsule.approved.find_by(id: params[:id])
        return render json: { error: 'Cápsula no encontrada' }, status: :not_found unless capsule
        return render json: { error: 'Esta cápsula no tiene voz configurada' }, status: :unprocessable_entity unless capsule.user.elevenlabs_voice_id.present?

        text = params[:text].to_s.strip
        return render json: { error: 'No hay contenido para narrar' }, status: :unprocessable_entity if text.blank?

        audio = ElevenLabsService.new.generate_speech(
          voice_id: capsule.user.elevenlabs_voice_id,
          text: text
        )
        send_data audio, type: 'audio/mpeg', disposition: 'inline', filename: 'memoria.mp3'
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # Genera un relato completo de todas las memorias con GPT y lo narra con la voz del dueño
      def narrate_story
        capsule = Capsule.approved.find_by(id: params[:id])
        return render json: { error: 'Cápsula no encontrada' }, status: :not_found unless capsule
        return render json: { error: 'Esta cápsula no tiene voz configurada' }, status: :unprocessable_entity unless capsule.user.elevenlabs_voice_id.present?

        memories = capsule.memories.where(memory_type: 'text').pluck(:content)
        return render json: { error: 'No hay memorias en esta cápsula' }, status: :unprocessable_entity if memories.blank?

        story = StoryNarratorService.new(capsule).generate_story
        audio = ElevenLabsService.new.generate_speech(
          voice_id: capsule.user.elevenlabs_voice_id,
          text: story
        )

        response.headers['X-Story-Text'] = story.encode('UTF-8')
        send_data audio, type: 'audio/mpeg', disposition: 'inline', filename: 'relato.mp3'
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end
  end
end

module Api
  module V1
    class PublicCapsulesController < ActionController::API
      MAX_NARRATE_TEXT_LENGTH = 2000

      def show
        capsule = Capsule.approved.find_by(id: params[:id])
        return render json: { error: 'Cápsula no encontrada' }, status: :not_found unless capsule

        render json: {
          id: capsule.id,
          title: capsule.title,
          description: capsule.description,
          open_at: capsule.open_at,
          has_voice: capsule.user.elevenlabs_voice_id.present?,
          # Nunca exponer el email del dueño en endpoints públicos
          owner_name: capsule.user.first_name,
          text_memories: capsule.memories.where(memory_type: 'text').order(:created_at).map do |m|
            { id: m.id, content: m.content }
          end,
          media_memories: capsule.memories.where.not(memory_type: 'text').order(:created_at).map do |m|
            {
              id: m.id,
              memory_type: m.memory_type,
              url: m.file.attached? ? signed_s3_url(m) : nil
            }
          end
        }
      end

      def narrate
        capsule = Capsule.approved.find_by(id: params[:id])
        return render json: { error: 'Cápsula no encontrada' }, status: :not_found unless capsule
        return render json: { error: 'Esta cápsula no tiene voz configurada' }, status: :unprocessable_entity unless capsule.user.elevenlabs_voice_id.present?

        text = params[:text].to_s.strip
        return render json: { error: 'No hay contenido para narrar' }, status: :unprocessable_entity if text.blank?

        if text.length > MAX_NARRATE_TEXT_LENGTH
          return render json: { error: "El texto no puede superar #{MAX_NARRATE_TEXT_LENGTH} caracteres" }, status: :unprocessable_entity
        end

        audio = ElevenLabsService.new.generate_speech(
          voice_id: capsule.user.elevenlabs_voice_id,
          text: text
        )
        send_data audio, type: 'audio/mpeg', disposition: 'inline', filename: 'memoria.mp3'
      rescue => e
        Rails.logger.error "PublicCapsules#narrate error: #{e.class}: #{e.message}"
        render json: { error: 'Error al generar el audio' }, status: :internal_server_error
      end

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

        # No poner contenido personal en headers HTTP (quedan en logs de proxies)
        send_data audio, type: 'audio/mpeg', disposition: 'inline', filename: 'relato.mp3'
      rescue => e
        Rails.logger.error "PublicCapsules#narrate_story error: #{e.class}: #{e.message}"
        render json: { error: 'Error al generar el relato' }, status: :internal_server_error
      end

      private

      def signed_s3_url(memory)
        memory.file.blob.service.url(
          memory.file.key,
          expires_in: 10.minutes,
          disposition: 'inline',
          filename: memory.file.filename,
          content_type: memory.file.blob.content_type
        )
      rescue => e
        Rails.logger.error "Error generating S3 URL: #{e.message}"
        nil
      end
    end
  end
end

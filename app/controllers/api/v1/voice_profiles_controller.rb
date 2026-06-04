module Api
  module V1
    class VoiceProfilesController < ActionController::API
      before_action :authenticate_user!

      # GET /api/v1/voice_profile
      def show
        render json: {
          has_voice: current_user.elevenlabs_voice_id.present?,
          voice_clone_status: current_user.voice_clone_status,
          samples_count: current_user.voice_samples.count
        }
      end

      # POST /api/v1/voice_samples
      def create_sample
        sample = current_user.voice_samples.new
        sample.audio.attach(params[:audio])
        if sample.save
          render json: { id: sample.id, message: 'Muestra guardada' }, status: :created
        else
          render json: { errors: sample.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/voice_samples/:id
      def destroy_sample
        sample = current_user.voice_samples.find_by(id: params[:id])
        if sample
          sample.destroy
          render json: { message: 'Muestra eliminada' }
        else
          render json: { error: 'Muestra no encontrada' }, status: :not_found
        end
      end

      # POST /api/v1/voice_profile/clone
      def clone
        if current_user.voice_samples.count < 1
          render json: { error: 'Necesitás al menos 1 muestra de voz' }, status: :unprocessable_entity
          return
        end

        if current_user.elevenlabs_voice_id.present?
          ElevenLabsService.new.delete_voice(current_user.elevenlabs_voice_id) rescue nil
        end

        current_user.update(voice_clone_status: 'pending', elevenlabs_voice_id: nil)
        VoiceCloningWorker.perform_async(current_user.id)
        render json: { message: 'Clonación iniciada', status: 'pending' }
      end

      # POST /api/v1/voice_profile/preview
      def preview
        unless current_user.elevenlabs_voice_id.present?
          render json: { error: 'Primero cloná tu voz' }, status: :unprocessable_entity
          return
        end

        text = params[:text].presence || '¡Hola! Soy yo, hablando desde mis recuerdos en Renace.'
        audio_data = ElevenLabsService.new.generate_speech(
          voice_id: current_user.elevenlabs_voice_id,
          text: text
        )
        send_data audio_data, type: 'audio/mpeg', disposition: 'inline', filename: 'preview.mp3'
      rescue => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end

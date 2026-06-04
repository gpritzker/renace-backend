module Api
  module V1
    class ConversationsController < ActionController::API
      # Endpoint público — no requiere login del visitante
      def chat
        capsule = Capsule.approved.find_by(id: params[:capsule_id])
        unless capsule
          render json: { error: 'Cápsula no encontrada o no disponible' }, status: :not_found
          return
        end

        unless capsule.user.elevenlabs_voice_id.present?
          render json: { error: 'Esta cápsula no tiene voz configurada aún' }, status: :unprocessable_entity
          return
        end

        message = params[:message].to_s.strip
        if message.blank?
          render json: { error: 'El mensaje no puede estar vacío' }, status: :unprocessable_entity
          return
        end

        history = Array(params[:history]).map do |h|
          { 'role' => h[:role] || h['role'], 'content' => h[:content] || h['content'] }
        end

        result = ConversationService.new(capsule).chat(message: message, history: history)

        # Siempre devolvemos JSON con text + audio en base64 (evita problemas de encoding en headers)
        render json: {
          text: result[:text],
          audio_base64: result[:audio] ? Base64.strict_encode64(result[:audio]) : nil
        }
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end
    end
  end
end

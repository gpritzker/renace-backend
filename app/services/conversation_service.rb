require 'openai'

class ConversationService
  MAX_RETRIES = 3
  RETRY_DELAY = 2

  def initialize(capsule)
    @capsule = capsule
    @user = capsule.user
    @client = OpenAI::Client.new(
      access_token: ENV.fetch('OPENAI_API_KEY'),
      request_timeout: 30
    )
  end

  def chat(message:, history: [])
    text = with_retries { generate_text(message: message, history: history) }
    audio = generate_audio(text, retries: 1)
    { text: text, audio: audio }
  end

  private

  def generate_text(message:, history:)
    messages = [{ role: 'system', content: system_prompt }]
    history.last(6).each { |h| messages << { role: h['role'], content: h['content'] } }
    messages << { role: 'user', content: message }

    response = @client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: messages,
        max_tokens: 200,
        temperature: 0.85
      }
    )

    if response.dig('error', 'code') == 'rate_limit_exceeded'
      raise RateLimitError, response.dig('error', 'message')
    end
    content = response.dig('choices', 0, 'message', 'content')
    raise "OpenAI sin respuesta: #{response}" if content.blank?
    content
  end

  def generate_audio(text, retries: 1)
    return nil unless @user.elevenlabs_voice_id.present?
    with_retries(retries: retries) { ElevenLabsService.new.generate_speech(voice_id: @user.elevenlabs_voice_id, text: text) }
  rescue => e
    Rails.logger.error "ElevenLabs TTS falló: #{e.message}"
    nil
  end

  def with_retries(retries: MAX_RETRIES, &block)
    attempts = 0
    begin
      result = block.call
      # ruby-openai devuelve errores en el body en vez de levantar excepción
      if result.is_a?(Hash) && result.dig('error', 'code') == 'rate_limit_exceeded'
        raise RateLimitError, result.dig('error', 'message')
      end
      result
    rescue RateLimitError, Faraday::TooManyRequestsError => e
      attempts += 1
      if attempts < retries
        sleep(RETRY_DELAY * attempts)
        retry
      end
      raise RuntimeError, 'Demasiadas solicitudes a la IA. Intentá de nuevo en unos segundos.'
    end
  end

  RateLimitError = Class.new(StandardError)

  def system_prompt
    memories_text = @capsule.memories.where(memory_type: 'text').map(&:content).join("\n- ")

    <<~PROMPT
      Sos #{@user.email.split('@').first}, una persona real.
      Estás hablando desde tus recuerdos guardados en una cápsula del tiempo llamada "#{@capsule.title}".

      Descripción de tu cápsula: #{@capsule.description}

      Tus memorias y recuerdos:
      - #{memories_text.presence || 'Todavía no tengo memorias escritas en esta cápsula.'}

      Respondé siempre en primera persona, con calidez y naturalidad, como si estuvieras contándole algo a alguien querido.
      Hablá en español rioplatense (vos, che, etc.).
      Si no sabés algo o no está en tus memorias, decilo con humildad.
      Respuestas cortas y conversacionales — máximo 3 oraciones.
    PROMPT
  end
end

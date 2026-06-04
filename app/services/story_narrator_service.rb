require 'openai'

class StoryNarratorService
  def initialize(capsule)
    @capsule = capsule
    @user = capsule.user
    @client = OpenAI::Client.new(access_token: ENV.fetch('OPENAI_API_KEY'), request_timeout: 30)
  end

  def generate_story
    memories_text = @capsule.memories.where(memory_type: 'text').pluck(:content).join("\n- ")
    owner_name = @user.email.split('@').first

    response = @client.chat(
      parameters: {
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'system',
            content: <<~PROMPT
              Sos #{owner_name}, una persona real que va a contarle un recuerdo a alguien querido.
              Hablá en primera persona, en español rioplatense (vos, che, etc.), con calidez y emoción.
              Convertí los recuerdos en un relato fluido y emotivo, como si lo estuvieras contando de viva voz.
              No uses títulos ni listas. Solo un relato continuo, natural, de 3 a 5 oraciones.
            PROMPT
          },
          {
            role: 'user',
            content: <<~CONTENT
              Cápsula: "#{@capsule.title}"
              Descripción: #{@capsule.description}

              Mis recuerdos:
              - #{memories_text}

              Contá este recuerdo como si se lo estuvieras relatando a alguien que querés.
            CONTENT
          }
        ],
        max_tokens: 350,
        temperature: 0.9
      }
    )

    story = response.dig('choices', 0, 'message', 'content')
    raise 'No se pudo generar el relato' if story.blank?
    story
  end
end

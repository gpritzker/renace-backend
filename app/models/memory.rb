class Memory < ApplicationRecord
    belongs_to :capsule
  
    has_one_attached :file # 👈 Esto habilita Active Storage
  
    enum memory_type: { text: 'text', image: 'image', video: 'video', audio: 'audio' }
  
    validates :content, presence: true, if: -> { text? } # solo se requiere content si es texto
    validates :memory_type, presence: true, inclusion: { in: memory_types.keys }
end
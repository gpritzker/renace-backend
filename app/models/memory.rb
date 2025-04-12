# frozen_string_literal: true

class Memory < ApplicationRecord
    belongs_to :capsule
  
    enum memory_type: { text: 'text', image: 'image', video: 'video', audio: 'audio' }
  
    validates :content, presence: true
    validates :memory_type, presence: true, inclusion: { in: ['text', 'image', 'audio', 'video'] }
end
  
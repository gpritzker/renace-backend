# app/models/user.rb
class User < ApplicationRecord
       # Módulos Devise habilitados
       devise :database_authenticatable, :registerable,
              :recoverable, :rememberable, :validatable,
              :confirmable, :jwt_authenticatable, jwt_revocation_strategy: self
     
       # Estrategia para revocar JWT basada en JTI
       include Devise::JWT::RevocationStrategies::JTIMatcher
     
       # Relaciones
       has_many :capsules, dependent: :destroy
       has_many :voice_samples, dependent: :destroy
end
     
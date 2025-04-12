# app/models/capsule.rb
# frozen_string_literal: true

class Capsule < ApplicationRecord
    belongs_to :user
    has_many :memories, dependent: :destroy
  
    validates :title, presence: true
    validates :description, presence: true
  end
  
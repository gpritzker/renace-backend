# app/models/capsule.rb
# frozen_string_literal: true

class Capsule < ApplicationRecord
    belongs_to :user
    has_many :memories, dependent: :destroy
  
    validates :title, presence: true
    validates :description, presence: true
    scope :approved, -> { where(approved: true) }
    scope :pending_approval, -> { where(approved: false) }
    scope :recent, -> { order(created_at: :desc) }
  
    def approve!
      update(approved: true)
    end
  
    def disapprove!
      update(approved: false)
    end
  
    def self.search(query)
      where('title LIKE ? OR description LIKE ?', "%#{query}%", "%#{query}%")
    end
  
    def self.filter_by_date(start_date, end_date)
      where(created_at: start_date..end_date)
    end
    def self.filter_by_user(user_id)
      where(user_id: user_id)
    end
  
    def self.filter_by_approved(approved)
      where(approved: approved)
    end
  
    def self.filter_by_open_at(open_at)
      where(open_at: open_at)
    end
    def self.filter_by_memory_count(min_count, max_count)
      joins(:memories)
        .group('capsules.id')
        .having('COUNT(memories.id) BETWEEN ? AND ?', min_count, max_count)
    end
  
    def self.sort_by(sort_by)
      case sort_by
      when 'title'
        order('title ASC')
      when 'created_at'
        order('created_at DESC')
      else
        all
      end
    end
    def self.paginate(page, per_page)
      offset((page - 1) * per_page).limit(per_page)
    end
  
    def self.filter_by_multiple_criteria(criteria)
      capsules = all
      criteria.each do |key, value|
        case key
        when :user_id
          capsules = capsules.filter_by_user(value)
        when :approved
          capsules = capsules.filter_by_approved(value)
        when :open_at
          capsules = capsules.filter_by_open_at(value)
        when :memory_count
          capsules = capsules.filter_by_memory_count(value[:min], value[:max])
        end
      end
      capsules
    end
    def self.search_and_filter(query, filters) 
      capsules = search(query)
      filters.each do |key, value|
        case key
        when :approved
          capsules = capsules.filter_by_approved(value)
        when :user_id
          capsules = capsules.filter_by_user(value)
        when :open_at
          capsules = capsules.filter_by_open_at(value)
        when :memory_count
          capsules = capsules.filter_by_memory_count(value[:min], value[:max])
        end
      end
      capsules
    end
  
    def self.sort_and_paginate(sort_by, page, per_page)
      sort_by(sort_by).paginate(page, per_page)
    end
  end
  
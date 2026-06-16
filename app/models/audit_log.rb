class AuditLog < ApplicationRecord
  belongs_to :user, optional: true

  ACTIONS = %w[
    login login_failed logout
    password_changed email_changed
    account_locked account_unlocked
    capsule_created capsule_updated capsule_deleted capsule_shared
    memory_created memory_updated memory_deleted
    file_uploaded file_downloaded
    permission_changed
    admin_login admin_action
    two_factor_enabled two_factor_disabled
    subscription_activated subscription_cancelled
  ].freeze

  validates :action, presence: true, inclusion: { in: ACTIONS }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :since, ->(time) { where('created_at >= ?', time) }

  def self.record(action:, user: nil, resource: nil, request: nil, metadata: {})
    log_data = {
      action: action,
      user: user,
      metadata: metadata
    }

    if resource
      log_data[:resource_type] = resource.class.name
      log_data[:resource_id]   = resource.id
    end

    if request
      log_data[:ip_address] = request.remote_ip
      log_data[:user_agent] = request.user_agent&.truncate(512)
      log_data[:session_id] = request.session.id.to_s.first(32) rescue nil
    end

    create!(log_data)
  rescue => e
    Rails.logger.error "AuditLog.record failed: #{e.message}"
  end
end

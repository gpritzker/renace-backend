module Auditable
  extend ActiveSupport::Concern

  def audit(action, resource: nil, metadata: {})
    AuditLog.record(
      action: action,
      user: try(:current_user) || try(:current_admin_user),
      resource: resource,
      request: request,
      metadata: metadata
    )
  end
end

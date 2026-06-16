class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: true, foreign_key: true
      t.string :action,        null: false
      t.string :resource_type
      t.bigint :resource_id
      t.string :ip_address
      t.string :user_agent
      t.jsonb  :metadata,      default: {}
      t.string :session_id
      t.timestamps
    end

    add_index :audit_logs, :action
    add_index :audit_logs, [:resource_type, :resource_id]
    add_index :audit_logs, :created_at
    add_index :audit_logs, [:user_id, :created_at]
  end
end

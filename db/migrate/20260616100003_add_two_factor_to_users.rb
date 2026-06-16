class AddTwoFactorToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :otp_secret, :string
    add_column :users, :otp_enabled, :boolean, default: false, null: false
    add_column :users, :otp_backup_codes, :text, array: true, default: []
  end
end

class AddSidekiqJidToCapsules < ActiveRecord::Migration[7.1]
  def change
    add_column :capsules, :sidekiq_jid, :string
  end
end

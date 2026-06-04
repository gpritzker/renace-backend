class AddVoiceFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :elevenlabs_voice_id, :string
    add_column :users, :voice_clone_status, :string, default: 'none'
  end
end

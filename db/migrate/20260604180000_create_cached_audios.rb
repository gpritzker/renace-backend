class CreateCachedAudios < ActiveRecord::Migration[7.1]
  def change
    create_table :cached_audios do |t|
      t.string :cache_key, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :cached_audios, :cache_key, unique: true
  end
end

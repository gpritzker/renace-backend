class RenameCacheKeyInCachedAudios < ActiveRecord::Migration[7.1]
  def change
    rename_column :cached_audios, :cache_key, :lookup_key
  end
end

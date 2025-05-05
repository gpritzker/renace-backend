class RemoveMediaUrlFromMemories < ActiveRecord::Migration[7.1]
  def change
    remove_column :memories, :media_url, :string
  end
end

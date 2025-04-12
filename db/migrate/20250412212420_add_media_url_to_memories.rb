class AddMediaUrlToMemories < ActiveRecord::Migration[7.1]
  def change
    add_column :memories, :media_url, :string
  end
end

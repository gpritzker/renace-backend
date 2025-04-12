class CreateMemories < ActiveRecord::Migration[7.1]
  def change
    create_table :memories do |t|
      t.text :content
      t.string :memory_type
      t.references :capsule, null: false, foreign_key: true

      t.timestamps
    end
  end
end

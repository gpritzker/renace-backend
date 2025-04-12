class CreateCapsules < ActiveRecord::Migration[7.1]
  def change
    create_table :capsules do |t|
      t.string :title
      t.text :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

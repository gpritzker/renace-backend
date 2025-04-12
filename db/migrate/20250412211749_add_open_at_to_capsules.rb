class AddOpenAtToCapsules < ActiveRecord::Migration[7.1]
  def change
    add_column :capsules, :open_at, :datetime
  end
end
